defmodule ParallelBinaryMerger do
  require Logger

  @moduledoc """
  Documentation for `ParallelBinaryMerger`.
  """

  @doc """
  Documentation for `receive_insert`.
  """
  @spec receive_insert(pid, list({Range.t(), non_neg_integer, list})) ::
          list({Range.t(), non_neg_integer, list})
  def receive_insert(pid, from..to) do
    receive_insert(pid, Enum.to_list(from..to))
  end

  def receive_insert(pid, list) when is_list(list) do
    result = receive_insert_sub(list, [])
    send(pid, result)
  end

  defp receive_insert_sub([], result) do
    result
  end

  defp receive_insert_sub(list, result) do
    receive do
      [] ->
        receive_insert_sub(list, result)

      l = [{_from.._to, _count, _fragment} | _tail] ->
        r = BinaryMerger.insert(result, l)
        receive_insert_sub(remove(list, l), r)
    after
      1000 ->
        raise(
          "Timeout list = #{inspect(list, charlists: :as_lists)}, result = #{inspect(result)}"
        )
    end
  end

  defp remove(list, from..to) do
    if from <= to do
      Enum.filter(list, &(&1 < from or to < &1))
    else
      Enum.filter(list, &(&1 < to or from < &1))
    end
  end

  defp remove(list, []), do: list

  defp remove(list, [{from..to, _count, _fragment} | tail]) do
    remove(list, from..to)
    |> remove(tail)
  end
end
