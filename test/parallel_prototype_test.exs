defmodule ParallelPrototypeTest do
  use ExUnit.Case
  doctest ParallelPrototype

  test "pmap" do
    assert ParallelPrototype.pmap(1..100, &(&1 * 2), 10) == Enum.map(1..100, &(&1 * 2))
  end

  test "pmap_chunk" do
    assert ParallelPrototype.pmap_chunk(1..100, &(&1 * 2), fn x -> Enum.map(x, &(&1 * 2)) end, 10) ==
             Enum.map(1..100, &(&1 * 2))
  end
end
