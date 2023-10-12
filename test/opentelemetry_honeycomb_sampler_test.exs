defmodule OpentelemetryHoneycombSamplerTest do
  use ExUnit.Case
  doctest OpentelemetryHoneycombSampler

  test "greets the world" do
    assert OpentelemetryHoneycombSampler.hello() == :world
  end
end
