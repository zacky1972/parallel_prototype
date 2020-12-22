defmodule BinaryMerger do
  @moduledoc """
  Documentation for `BinaryMerger`.
  """

  @doc """
  ## Examples

  iex> BinaryMerger.insert({{3..4, 2, [3, 4]}, nil}, {1..2, 2, [1, 2]})
  {{1..4, 4, [1, 2, 3, 4]}, nil}

  iex> BinaryMerger.insert({nil, {1..2, 2, [1, 2]}}, {3..4, 2, [3, 4]})
  {nil, {1..4, 4, [1, 2, 3, 4]}}

  iex> BinaryMerger.insert({1..2, 2, [1, 2]}, {5..6, 2, [5, 6]})
  {{1..2, 2, [1, 2]}, {5..6, 2, [5, 6]}}

  iex> BinaryMerger.insert({{1..2, 2, [1, 2]}, {5..6, 2, [5, 6]}}, {3..4, 2, [3, 4]})
  {1..6, 6, [1, 2, 3, 4, 5, 6]}  

  """
  @spec insert(
          nil
          | {Range.t(), non_neg_integer, list}
          | tuple,
          {Range.t(), non_neg_integer, list}
        ) ::
          {Range.t(), non_neg_integer, list}
          | {{Range.t(), non_neg_integer, list}, {Range.t(), non_neg_integer, list}}
  def insert(nil, {from_i..to_i, count_i, fragment_i}) do
    {from_i..to_i, count_i, fragment_i}
  end

  def insert({from..to, count, fragment}, {from_i..to_i, count_i, fragment_i}) do
    Merger.merge({from..to, count, fragment}, {from_i..to_i, count_i, fragment_i})
  end

  def insert(
        {{from_left..to_left, count_left, fragment_left}, right},
        {from_i..to_i, count_i, fragment_i}
      )
      when from_i <= to_i and to_i < from_left and from_left <= to_left do
    {
      Merger.merge(
        {from_i..to_i, count_i, fragment_i},
        {from_left..to_left, count_left, fragment_left}
      ),
      right
    }
  end

  def insert(
        {left, {from_right..to_right, count_right, fragment_right}},
        {from_i..to_i, count_i, fragment_i}
      )
      when from_right <= to_right and to_right < from_i and from_i <= to_i do
    {
      left,
      Merger.merge(
        {from_right..to_right, count_right, fragment_right},
        {from_i..to_i, count_i, fragment_i}
      )
    }
  end

  def insert(
        {
          left,
          {from_right..to_right, count_right, fragment_right}
        },
        {from_i..to_i, count_i, fragment_i}
      )
      when to_i < from_right do
    BinaryMerger.insert(
      left,
      {from_i..to_i, count_i, fragment_i}
    )
    |> BinaryMerger.insert({from_right..to_right, count_right, fragment_right})
  end

  def insert(
        {
          {from_left..to_left, count_left, fragment_left},
          right
        },
        {from_i..to_i, count_i, fragment_i}
      )
      when to_left < from_i do
    BinaryMerger.insert(right, {from_i..to_i, count_i, fragment_i})
    |> BinaryMerger.insert({from_left..to_left, count_left, fragment_left})
  end
end
