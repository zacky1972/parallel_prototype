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
  def pmap(enumerable, fun, threshold \\ 1000) do
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

    ParallelBinaryMerger.receive_insert(self(), ParallelSplitter.range(enumerable, threshold))

    [{_from.._to, _count, result}] = receive_result([], p_list, enumerable, threshold, fun)

    result
  end

  defp receive_result(result, p_list, enumerable, threshold, fun) do
    receive do
      {:DOWN, _ref, :process, pid, :normal} ->
        receive_result(result, remove(p_list, pid), enumerable, threshold, fun)

      {:DOWN, _ref, :process, pid, _} ->
        {{_pid, _ref}, id} = find(p_list, pid)
        fallback_result = [{id..id, threshold, fallback(enumerable, id, threshold, fun)}]
        result = BinaryMerger.insert(result, fallback_result)
        receive_result(result, remove(p_list, pid), enumerable, threshold, fun)

      list = [{_from.._to, _count, _fragment}] ->
        BinaryMerger.insert(result, list)
    after
      500 ->
        result
    end
  end

  defp remove(p_list, o_pid) do
    Enum.filter(p_list, fn {{pid, _ref}, _id} -> o_pid != pid end)
  end

  defp find(p_list, o_pid) do
    Enum.find(p_list, fn {{pid, _ref}, _id} -> o_pid == pid end)
  end

  @spec fallback(Enum.t(), non_neg_integer(), pos_integer(), (Enum.element() -> any())) :: list()
  def fallback(enumerable, id, threshold, fun) do
    enumerable
    |> Enum.slice(id * threshold, threshold)
    |> Enum.map(fun)
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
end
