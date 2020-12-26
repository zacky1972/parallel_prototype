defmodule ParallelPrototypeTest do
  use ExUnit.Case
  doctest ParallelPrototype

  test "pmap" do
    assert ParallelPrototype.pmap(1..100, &(&1 * 2), 10) == Enum.map(1..100, &(&1 * 2))
  end
end
