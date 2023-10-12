defmodule OpentelemetryHoneycombSampler do
  @moduledoc """
  Honeycomb Sampler for OpenTelemetry.

  Usage:

  config :opentelemetry,
    :sampler, {OpentelemetryHoneycombSampler, %{root: {MySampler, %{}}}}
  """
  @behaviour :otel_sampler

  alias OpentelemetryHoneycombSampler.AlwaysOnSampleRatePropagator

  @impl :otel_sampler
  def setup(%{root: {_module, _opts}} = opts) do
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
