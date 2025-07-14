defmodule OpentelemetryHoneycombSampler do
  @external_resource "README.md"
  @moduledoc @external_resource
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

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

  def add_sample_rate({result, attrs, tracestate}, sample_rate) do
    #
    # Add SampleRate to the:
    # - attributes, so that Honeycomb can account for the non-sampled spans
    # - tracestate, so that we can propagate the SampleRate to the attributes of child spans
    # (Note: the tracestate key must begin with a lowercase character, which is why the key is cased differently between attrs and tracestate. Otherwise it is silently discarded.)
    #
    {
      result,
      [{:SampleRate, sample_rate} | attrs],
      :otel_tracestate.update("samplerate", to_string(sample_rate), tracestate)
    }
  end
end
