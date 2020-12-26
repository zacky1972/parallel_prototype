defmodule ParallelSplitter do
  @moduledoc """
  Documentation for `ParallelSplitter`.
  """

  @doc """
  Returns list of processes or tuples of a process and a reference 
  that spawns the given function `fun` from module `mod`, 
  passing `pid`, a list containing `threshold` elements each, and `id` of the list,
  according to the given options.

  The result depends on the given options. 
  In particular, if `:monitor` is given as an option,
  it will return list of tuples containing the PID and the monitoring reference,
  otherwise just the spawned process PID.

  It also accepts extra options, for the list of available options check `:erlang.spawn_opt/4`. 
  """
  @spec split({module(), atom()}, pid(), non_neg_integer(), Enum.t(), pos_integer(), Process.spawn_opts()) ::
          [pid() | {pid(), reference()}]
  def split({_, _}, _, _, [], _, _), do: []

  def split({mod, fun}, pid, id, enumerable, threshold, opts) do
    {heads, tail} = Enum.split(enumerable, threshold)

    [
      Process.spawn(mod, fun, [pid, heads, id], opts)
      | split({mod, fun}, pid, id + 1, tail, threshold, opts)
    ]
  end
end
