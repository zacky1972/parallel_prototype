defmodule BinaryMerger do
  @moduledoc """
  Documentation for `BinaryMerger`.
  """

  @doc """
  ## Examples

  iex> BinaryMerger.insert([{1..2, 2, [1, 2]}], [{5..6, 2, [5, 6]}])
  [{1..2, 2, [1, 2]}, {5..6, 2, [5, 6]}]

  iex> BinaryMerger.insert([{1..2, 2, [1, 2]}, {5..6, 2, [5, 6]}], [{3..4, 2, [3, 4]}])
  [{1..6, 6, [1, 2, 3, 4, 5, 6]}]  

  """
  @spec insert(
          list({Range.t(), non_neg_integer, list}),
          list({Range.t(), non_neg_integer, list})
        ) ::
          list({Range.t(), non_neg_integer, list})
  def insert([], [{from_i..to_i, count_i, fragment_i}]) do
    [{from_i..to_i, count_i, fragment_i}]
  end

  def insert(
        [head = {_from_head.._to_head, _count_head, _fragment_head} | tail],
        i = [{_from_i.._to_i, _count_i, _fragment_i}]
      ) do
    r = Merger.merge([head], i)

    if Enum.count(r) > 1 do
      Merger.merge(tail, i) |> Merger.merge([head])
    else
      Merger.merge(tail, r)
    end
  end
end
