defmodule OpentelemetryHoneycombSampler.AlwaysOnSampleRatePropagator do
  @moduledoc """
  Propagate SampleRate so that counts of child spans are accurately shown in Honeycomb
  """

  @behaviour :otel_sampler

  @impl :otel_sampler
  def setup(_sampler_opts) do
    []
  end

  @impl :otel_sampler
  def description(_sampler_config) do
    "AlwaysOnSampleRatePropagator"
  end

  @impl :otel_sampler
  def should_sample(
        ctx,
        trace_id,
        links,
        span_name,
        span_kind,
        attributes,
        _sampler_config
      ) do
    {result, _attrs, tracestate} =
      :otel_sampler_always_on.should_sample(
        ctx,
        trace_id,
        links,
        span_name,
        span_kind,
        attributes,
        []
      )
      |> OpentelemetryHoneycombSampler.add_sample_rate(get_sample_rate(ctx))
  end

  @spec get_sample_rate(:otel_ctx.t()) :: pos_integer() | nil
  defp get_sample_rate(ctx) do
    parent_tracestate =
      :otel_tracer.current_span_ctx(ctx)
      |> :otel_span.tracestate()

    :otel_tracestate.get("samplerate", parent_tracestate)
    |> to_string
    |> Integer.parse()
    |> case do
      {sample_rate, ""} when sample_rate > 0 -> sample_rate
      _ -> 1
    end
  end
end
