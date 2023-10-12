defmodule OpentelemetryHoneycombSampler do
  @moduledoc """
  Honeycomb Sampler for OpenTelemetry.

  Usage:

  config :opentelemetry,
    :sampler, {OpentelemetryHoneycombSampler, %{root: {MySampler, %{}}}}
  """

  @callback setup(:otel_sampler.sampler_opts()) :: :otel_sampler.sampler_config()
  @callback description(:otel_sampler.sampler_config()) :: :otel_sampler.description()
  @callback should_sample(
              :otel_ctx.t(),
              :opentelemetry.trace_id(),
              :otel_links.t(),
              :opentelemetry.span_name(),
              :opentelemetry.span_kind(),
              :opentelemetry.attributes_map(),
              :otel_sampler.sampler_config()
            ) :: pos_integer()

  @behaviour :otel_sampler

  alias OpentelemetryHoneycombSampler.AlwaysOnSampleRatePropagator

  @impl :otel_sampler
  def setup(%{root: {module, module_opts}} = opts) do
    opts = Map.put(opts, :module_config, module.setup(module_opts))

    :otel_sampler_parent_based.setup(%{
      root: {__MODULE__, opts},
      local_parent_sampled: {AlwaysOnSampleRatePropagator, %{}},
      remote_parent_sampled: {AlwaysOnSampleRatePropagator, %{}}
    })
  end

  @impl :otel_sampler
  def description(_config) do
    "Honeycomb Sampler"
  end

  # necessary until https://github.com/open-telemetry/opentelemetry-erlang/pull/615 is released
  @dialyzer {:nowarn_function, should_sample: 7}

  @impl :otel_sampler
  def should_sample(
        ctx,
        trace_id,
        links,
        span_name,
        span_kind,
        span_attrs,
        %{root: {module, config}}
      ) do
    sample_rate =
      case module.should_sample(ctx, trace_id, links, span_name, span_kind, span_attrs, config) do
        sample_rate when is_integer(sample_rate) and sample_rate > 0 ->
          sample_rate

        _ ->
          1
      end

    {result, _attrs, tracestate} =
      :otel_sampler_trace_id_ratio_based.should_sample(
        ctx,
        trace_id,
        links,
        span_name,
        span_kind,
        span_attrs,
        :otel_sampler_trace_id_ratio_based.setup(1.0 / sample_rate)
      )

    #
    # Add SampleRate to the:
    # - attributes, so that Honeycomb can account for the non-sampled spans
    # - tracestate, so that we can propagate the SampleRate to the attributes of child spans
    #
    {
      result,
      _attrs = [SampleRate: sample_rate],
      _tracestate = [{"SampleRate", sample_rate} | tracestate]
    }
  end
end
