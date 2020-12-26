defmodule ParallelPrototype do
  @moduledoc """
  Documentation for `ParallelPrototype`.
  """

  @doc """

  ## Examples

  iex> ParallelPrototype.pmap(1..3, & &1 * 2)
  [2, 4, 6]

  """
  @spec pmap(Enum.t(), (Enum.element() -> any()), pos_integer()) :: list()
  def pmap(enumerable, fun, threshold \\ 12000) do
    p_list =
      ParallelSplitter.split(
        {ParallelPrototype, :sub_enum},
        self(),
        0,
        enumerable,
        threshold,
        fun,
        [:monitor]
      )

    [{_from.._to, _count, result}] =
      ParallelBinaryMerger.receive_insert_fun(
        self(),
        p_list,
        fallback(enumerable, threshold, fun)
      )

    result
  end

  @spec pmap_chunk(Enum.t(), (Enum.element() -> any()), (Enum.t() -> Enum.t()), pos_integer()) ::
          list()
  def pmap_chunk(enumerable, fun, chunk_fun, threshold \\ 12000) do
    p_list =
      ParallelSplitter.split(
        {ParallelPrototype, :sub_chunk},
        self(),
        0,
        enumerable,
        threshold,
        chunk_fun,
        [:monitor]
      )

    [{_from.._to, _count, result}] =
      ParallelBinaryMerger.receive_insert_fun(
        self(),
        p_list,
        fallback(enumerable, threshold, fun)
      )

    result
  end

  @spec fallback(Enum.t(), pos_integer(), (Enum.element() -> any())) ::
          (non_neg_integer() -> list())
  def fallback(enumerable, threshold, fun) do
    fn id ->
      enumerable
      |> Enum.slice(id * threshold, threshold)
      |> Enum.map(fun)
    end
  end

  @spec sub_enum(pid(), Enum.t(), pos_integer(), (Enum.element() -> any())) ::
          [{Range.t(), non_neg_integer(), list()}]
  def sub_enum(pid, enumerable, id, fun) do
    send(
      pid,
      [
        {
          id..id,
          Enum.count(enumerable),
          Enum.map(enumerable, fun)
        }
      ]
    )

    exit(:normal)
  end

  @spec sub_chunk(pid(), Enum.t(), pos_integer(), (Enum.t() -> Enum.t())) ::
          [{Range.t(), non_neg_integer(), list()}]
  def sub_chunk(pid, enumerable, id, chunk_fun) do
    send(
      pid,
      [
        {
          id..id,
          Enum.count(enumerable),
          chunk_fun.(enumerable)
        }
      ]
    )
  end
end
