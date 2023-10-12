defmodule OpentelemetryHoneycombSampler.MixProject do
  use Mix.Project

  def project do
    [
      app: :opentelemetry_honeycomb_sampler,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:opentelemetry, "~> 1.2"},
      {:opentelemetry_api, "~> 1.2"}
    ]
  end
end
