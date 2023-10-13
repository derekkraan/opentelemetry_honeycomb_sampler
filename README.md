# OpentelemetryHoneycombSampler

<!-- MDOC !-->

Sample with Honeycomb!

This package provides a handy interface for sampling which is similar to how stock otel samplers work, but with all the messy details abstracted away. Simply pattern match on spans and set a sample rate.

This package also makes sure that SampleRate is set on the spans as required by Honeycomb. Honeycomb multiplies your span counts by this SampleRate to arrive at a reasonable estimate of the true number of spans. This is also being set on child spans, so those will also be estimated properly by Honeycomb (unlike, I believe, in many other HC samplers).

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

Honeycomb's sample rates are expressed as a positive integer N (1, 2, 3, 1000, etc). Their sample rate means "1 in N events will be sampled". In other words, if you return `10` from `should_sample/7`, then one in ten, or 10% of your events, will eventually be sent to Honeycomb.

A sample rate of 1, therefore, results in all of your events being sent to Honeycomb. This is as if you did not configure sampling at all.

## Installation

The package can be installed by adding `opentelemetry_honeycomb_sampler` to your list of dependencies in `mix.exs`:

The docs can be found at <https://hexdocs.pm/opentelemetry_honeycomb_sampler>.

## Thanks

Developed partially under contract at [Fairing.co](https://fairing.co).
