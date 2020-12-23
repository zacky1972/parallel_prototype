defmodule ParallelBinaryMerger do
  @moduledoc """
  Documentation for `ParallelBinaryMerger`.
  """

  @doc """
  Documentation for `receive_insert`.
  """
  @spec receive_insert(pid, Range.t() | list({Range.t(), non_neg_integer, list})) ::
          list({Range.t(), non_neg_integer, list})
  def receive_insert(pid, from..to) do
    receive_insert(pid, Enum.to_list(from..to))
  end

  def receive_insert(pid, list) when is_list(list) do
    send(pid, receive_insert_sub(list, []))
  end

  defp receive_insert_sub([], result), do: result

  defp receive_insert_sub(list, result) do
    receive do
      [] ->
        receive_insert_sub(list, result)
  
      l = [_head = {_from.._to, _count, _fragment} | _tail] ->
        receive_insert_sub(remove(list, l), BinaryMerger.insert(result, l))
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
