# OpentelemetryHoneycombSampler [![Hex pm](http://img.shields.io/hexpm/v/opentelemetry_honeycomb_sampler.svg?style=flat)](https://hex.pm/packages/opentelemetry_honeycomb_sampler) [![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/opentelemetry_honeycomb_sampler)

<!-- MDOC !-->

Sampling for Honeycomb comes with some additional challenges. This library helps you sample with Honeycomb and takes care of all the messy details.

- 💥 Honeycomb's `SampleRate` has its own format (`1/SampleRate` are sampled, where `SampleRate` is an integer and `> 0`). See below for an example.
- 💥 Honeycomb multiplies your spans by `SampleRate` to arrive at an estimate of the total number (sampled and unsampled) of spans.
- 💥 Honeycomb expects `SampleRate` to be set on child spans as well as parent spans. If you don't take care of this detail, then your child spans won't be multiplied by `SampleRate` and will therefore be underrepresented in your Honeycomb searches / dashboards.

This package provides a handy interface for sampling which is similar to how stock otel samplers work, but with all the messy details abstracted away. Simply pattern match on spans and set a sample rate.

## Getting started

Install the package:

```elixir
# mix.exs
def deps do
  [
    {:opentelemetry_honeycomb_sampler, "~> 0.1.0"}
  ]
end
```

Create a sampler module:

```elixir
# my_sampler.ex

defmodule MySampler do
  @behaviour OpentelemetryHoneycombSampler

  @impl OpentelemetryHoneycombSampler
  def description(_config), do: "MySampler"

  @impl OpentelemetryHoneycombSampler
  def setup(_config), do: []

  @impl OpentelemetryHoneycombSampler
  def sample_rate(
        _ctx,
        _trace_id,
        _links,
        _span_name,
        _span_kind,
        _span_attrs,
        _sampler_config
      ) do
    # 1 # all events will be sent
    # 2 # 50% of events will be sent
    # 3 # 33% of events will be sent
    # 4 # 25% of events will be sent
    1
  end
end
```

Add OpentelemetryHoneycombSampler to your `config/config.exs` or similar:

```elixir
# config/config.exs

config :opentelemetry,
  :sampler,
  {OpentelemetryHoneycombSampler, %{root: {MySampler, _my_config = %{}}}}
```

And that's all there is to it!

## A note about SampleRate

Make sure there is a catch-all function head at the very bottom of your file that returns the general sample rate that you would like to use.

Honeycomb's sample rates are expressed as a positive integer N (1, 2, 3, 1000, etc). Their sample rate means "1 in N events will be sampled". In other words, if you return `20` from `should_sample/7`, then one in twenty, or 5% of your events, will eventually be sent to Honeycomb.

A sample rate of 1, therefore, results in all of your events being sent to Honeycomb. This is as if you did not configure sampling at all.

## Thanks

Developed partially under contract at [Fairing.co](https://fairing.co).
