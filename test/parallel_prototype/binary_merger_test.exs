defmodule BinaryMergerTest do
  use ExUnit.Case
  doctest BinaryMerger

  defp element(id), do: {id..id, 10, Enum.to_list(1..10)}

  defp ascending do
  	Enum.reduce(
      Enum.map(1..100, &element(&1)),
      [],
      fn x, acc -> BinaryMerger.insert(acc, x) end
    )
  end

  defp descending do
  	Enum.reduce(
      Enum.map(100..1, &element(&1)),
      [],
      fn x, acc -> BinaryMerger.insert(acc, x) end
    )
  end

  defp random do
  	Enum.reduce(
      1..100 |> Enum.shuffle() |> Enum.map(&element(&1)),
      [],
      fn x, acc -> BinaryMerger.insert(acc, x) end
    )
  end

  test "equals inserting in ascending and descending order" do
    assert ascending() == descending()
  end

  test "equals inserting in ascending order and order at random" do
    assert ascending() == random()
  end
end
