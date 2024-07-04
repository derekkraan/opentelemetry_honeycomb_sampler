defmodule OpentelemetryHoneycombSampler.Sampler do
  @behaviour :otel_sampler

  @impl :otel_sampler
  def setup(config), do: config

  @impl :otel_sampler
  def description(_config), do: "OpentelemetryHoneycombSampler.Sampler"

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
    require Logger

    sample_rate =
      case module.sample_rate(ctx, trace_id, links, span_name, span_kind, span_attrs, config) do
        sample_rate when is_integer(sample_rate) and sample_rate > 0 ->
          sample_rate

        sample_rate ->
          Logger.warning(fn -> "Expected integer SampleRate, > 0; got #{inspect(sample_rate)}" end)

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
      _tracestate = :otel_tracestate.update("SampleRate", to_string(sample_rate), tracestate)
    }
  end
end
