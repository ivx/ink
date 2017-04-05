defmodule EncoderTest do
  use ExUnit.Case, async: true

  test "it can JSON encode PIDs" do
    assert Poison.encode!(%{pid: :c.pid(0, 250, 0)}) ==
      "{\"pid\":\"#PID<0.250.0>\"}"
  end

  test "it can JSON encode Ports" do
    port = Port.open({:spawn, "cat"}, [:binary])
    assert Poison.encode!(%{port: port}) =~ ~r/{\"port\":\"#Port<.+>\"}/
  end

  test "it can JSON encode References" do
    reference = Process.monitor(self())
    assert Poison.encode!(%{ref: reference}) =~ ~r/{\"ref\":\"#Reference<.+>\"}/
  end
end
