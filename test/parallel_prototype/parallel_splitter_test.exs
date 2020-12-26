defmodule ParallelSplitterTest do
  use ExUnit.Case
  doctest ParallelSplitter

  test "single" do
  	[{pid, ref}] = ParallelSplitter.split({SplitterHelper, :count}, self(), 1..10, 10, [:monitor])
  	receive do
  	  {:DOWN, ^ref, :process, ^pid, :normal} -> assert true

  	  msg -> 
  	  	IO.inspect msg
  	  	assert false

  	after 1000 
  	  -> assert false
  	end
  end

  test "double" do
  	[{_pid1, _ref1}, {_pid2, _ref2}] = ParallelSplitter.split({SplitterHelper, :count}, self(), 1..20, 10, [:monitor])
	receive_single()
	receive_single()
  end

  defp receive_single() do
  	receive do
  	  {:DOWN, _ref, :process, _pid, :normal} -> assert true

  	  msg -> 
  	  	IO.inspect msg
  	  	assert false

  	after 1000 
  	  -> assert false
  	end
  end
end
