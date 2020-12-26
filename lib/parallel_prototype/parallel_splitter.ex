defmodule ParallelSplitter do
  @moduledoc """
  Documentation for `ParallelSplitter`.
  """

  @doc """
  """
  @spec split({module(), atom()}, pid(), Enum.t(), pos_integer(), Process.spawn_opts()) ::
          [pid() | {pid(), reference()}]
  def split({_, _}, _, [], _, _), do: []

  def split({mod, fun}, pid, enumerable, threshold, opts) do
    {heads, tail} = Enum.split(enumerable, threshold)

    [
      Process.spawn(mod, fun, [pid, heads], opts)
      | split({mod, fun}, pid, tail, threshold, opts)
    ]
  end
end
