defmodule OpentelemetryHoneycombSampler.MixProject do
  use Mix.Project

  def project do
    [
      app: :opentelemetry_honeycomb_sampler,
      version: "1.0.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
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
      {:dialyxir, "~> 1.4", only: :dev},
      {:ex_doc, "> 0.0.0", only: :dev},
      {:opentelemetry, "~> 1.2"},
      {:opentelemetry_api, "~> 1.3"}
    ]
  end

  defp docs() do
    [main: "OpentelemetryHoneycombSampler"]
  end

  defp package do
    [
      licenses: ["MIT"],
      description: "Otel sampler for Honeycomb",
      maintainers: ["Derek Kraan"],
      links: %{GitHub: "https://github.com/derekkraan/opentelemetry_honeycomb_sampler"}
    ]
  end
end
