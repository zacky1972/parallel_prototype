defmodule Merger do
  @moduledoc """
  Documentation for `Merger`.
  """

  @doc """
  Merges two consecutive tuples of a `Range` and a list.

  ## Examples

  iex> Merger.merge({1..2, 4, [1, 2, 3, 4]}, {3..4, 4, [5, 6, 7, 8]})
  {1..4, 8, [1, 2, 3, 4, 5, 6, 7, 8]}

  iex> Merger.merge({3..4, 4, [5, 6, 7, 8]}, {1..2, 4, [1, 2, 3, 4]})
  {1..4, 8, [1, 2, 3, 4, 5, 6, 7, 8]}

  iex> Merger.merge({4..3, 4, [1, 2, 3, 4]}, {2..1, 4, [5, 6, 7, 8]})
  {4..1, 8, [1, 2, 3, 4, 5, 6, 7, 8]}

  iex> Merger.merge({2..1, 4, [5, 6, 7, 8]}, {4..3, 4, [1, 2, 3, 4]})
  {4..1, 8, [1, 2, 3, 4, 5, 6, 7, 8]}

  iex> Merger.merge({1..2, 4, [1, 2, 3, 4]}, {4..3, 4, [8, 7, 6, 5]})
  {1..4, 8, [1, 2, 3, 4, 5, 6, 7, 8]}

  iex> Merger.merge({1..2, 2, [3, 4]}, {4..3, 4, [8, 7, 6, 5]})
  {4..1, 6, [8, 7, 6, 5, 4, 3]}

  iex> Merger.merge({2..1, 4, [4, 3, 2, 1]}, {3..4, 4, [5, 6, 7, 8]})
  {4..1, 8, [8, 7, 6, 5, 4, 3, 2, 1]}

  iex> Merger.merge({2..1, 2, [4, 3]}, {3..4, 4, [5, 6, 7, 8]})
  {1..4, 6, [3, 4, 5, 6, 7, 8]}

  iex> Merger.merge({4..3, 4, [8, 7, 6, 5]}, {1..2, 4, [1, 2, 3, 4]})
  {4..1, 8, [8, 7, 6, 5, 4, 3, 2, 1]}

  iex> Merger.merge({4..3, 4, [8, 7, 6, 5]}, {1..2, 2, [3, 4]})
  {4..1, 6, [8, 7, 6, 5, 4, 3]}

  iex> Merger.merge({3..4, 4, [5, 6, 7, 8]}, {2..1, 4, [4, 3, 2, 1]})
  {4..1, 8, [8, 7, 6, 5, 4, 3, 2, 1]}

  iex> Merger.merge({3..4, 4, [5, 6, 7, 8]}, {2..1, 2, [4, 3]})
  {1..4, 6, [3, 4, 5, 6, 7, 8]}

  iex> Merger.merge({1..2, 2, [1, 2]}, {5..6, 2, [1, 2]})
  {{1..2, 2, [1, 2]}, {5..6, 2, [1, 2]}}

  """
  @spec merge({Range.t(), non_neg_integer, list}, {Range.t(), non_neg_integer, list}) ::
          {Range.t(), non_neg_integer, list} | tuple
  def merge({from_1..to_1, count_1, fragment_1}, {from_2..to_2, count_2, fragment_2}) do
    cond do
      from_1 <= to_1 and from_2 <= to_2 ->
        cond do
          to_1 + 1 == from_2 ->
            {from_1..to_2, count_1 + count_2, fragment_1 ++ fragment_2}

          to_2 + 1 == from_1 ->
            {from_2..to_1, count_1 + count_2, fragment_2 ++ fragment_1}

          to_1 < from_2 ->
            {{from_1..to_1, count_1, fragment_1}, {from_2..to_2, count_2, fragment_2}}

          to_2 < from_1 ->
            {{from_2..to_2, count_2, fragment_2}, {from_1..to_1, count_1, fragment_1}}
        end

      from_1 > to_1 and from_2 <= to_2 ->
        cond do
          from_1 + 1 == from_2 ->
            if count_1 < count_2 do
              {to_1..to_2, count_1 + count_2, Enum.reverse(fragment_1) ++ fragment_2}
            else
              {to_2..to_1, count_1 + count_2, Enum.reverse(fragment_2) ++ fragment_1}
            end

          to_2 + 1 == to_1 ->
            if count_1 < count_2 do
              {from_2..from_1, count_1 + count_2, fragment_2 ++ Enum.reverse(fragment_1)}
            else
              {from_1..from_2, count_1 + count_2, fragment_1 ++ Enum.reverse(fragment_2)}
            end

          from_1 < from_2 ->
            {{from_1..to_1, count_1, fragment_1}, {from_2..to_2, count_2, fragment_2}}

          to_2 < to_1 ->
            {{from_2..to_2, count_2, fragment_2}, {from_1..to_1, count_1, fragment_1}}
        end

      from_1 <= to_1 and from_2 > to_2 ->
        cond do
          to_1 + 1 == to_2 ->
            if count_1 < count_2 do
              {from_2..from_1, count_1 + count_2, fragment_2 ++ Enum.reverse(fragment_1)}
            else
              {from_1..from_2, count_1 + count_2, fragment_1 ++ Enum.reverse(fragment_2)}
            end

          from_2 + 1 == from_1 ->
            if count_1 > count_2 do
              {to_2..to_1, count_1 + count_2, Enum.reverse(fragment_2) ++ fragment_1}
            else
              {to_1..to_2, count_1 + count_2, Enum.reverse(fragment_1) ++ fragment_2}
            end

          to_1 < to_2 ->
            {{from_1..to_1, count_1, fragment_1}, {from_2..to_2, count_2, fragment_2}}

          to_2 < to_1 ->
            {{from_2..to_2, count_2, fragment_2}, {from_1..to_1, count_1, fragment_1}}
        end

      from_1 > to_1 and from_2 > to_2 ->
        cond do
          to_1 == from_2 + 1 ->
            {from_1..to_2, count_1 + count_2, fragment_1 ++ fragment_2}

          to_2 == from_1 + 1 ->
            {from_2..to_1, count_1 + count_2, fragment_2 ++ fragment_1}

          from_1 < to_2 ->
            {{from_1..to_1, count_1, fragment_1}, {from_2..to_2, count_2, fragment_2}}

          from_2 < to_1 ->
            {{from_2..to_2, count_2, fragment_2}, {from_1..to_1, count_1, fragment_1}}
        end
    end
  end
end
