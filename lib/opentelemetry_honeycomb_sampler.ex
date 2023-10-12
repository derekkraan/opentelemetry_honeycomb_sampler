defmodule OpentelemetryHoneycombSampler do
  @moduledoc """
  Honeycomb Sampler for OpenTelemetry.
  """

  @callback setup(:otel_sampler.sampler_opts()) :: :otel_sampler.sampler_config()
  @callback description(:otel_sampler.sampler_config()) :: :otel_sampler.description()
  @callback sample_rate(
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
  alias OpentelemetryHoneycombSampler.Sampler

  @impl :otel_sampler
  def setup(%{root: {module, module_opts}} = opts) do
    opts = Map.put(opts, :module_config, module.setup(module_opts))

    :otel_sampler_parent_based.setup(%{
      root: {Sampler, opts},
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
        config
      ) do
    :otel_sampler_parent_based.should_sample(
      ctx,
      trace_id,
      links,
      span_name,
      span_kind,
      span_attrs,
      config
    )
  end
end
