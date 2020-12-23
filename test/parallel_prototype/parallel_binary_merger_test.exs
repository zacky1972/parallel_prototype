defmodule ParallelBinaryMergerTest do
  use ExUnit.Case
  doctest ParallelBinaryMerger

  test "single" do
  	pid = spawn(ParallelBinaryMerger, :receive_insert, [self(), 1..1])
  	element_1 = MergerHelper.element(1)
  	send(pid, element_1)
  	receive do
  	  e -> assert e == element_1
  	after 1000 -> assert false
  	end
  end
end