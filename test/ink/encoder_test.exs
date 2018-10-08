defmodule Ink.EncoderTest do
  use ExUnit.Case, async: true

  defmodule TestStruct do
    defstruct [:field]
  end

  test "it can encode PIDs" do
    assert {:ok, ~s({"pid":"#PID<0.250.0>"})} ==
             Ink.Encoder.encode(%{pid: :c.pid(0, 250, 0)})
  end

  test "it can encode Ports" do
    port = Port.open({:spawn, "cat"}, [:binary])
    {:ok, result} = Ink.Encoder.encode(%{port: port})

    assert result =~ ~r/{\"port\":\"#Port<.+>\"}/
  end

  test "it can encode References" do
    reference = Process.monitor(self())
    {:ok, result} = Ink.Encoder.encode(%{ref: reference})

    assert result =~ ~r/{\"ref\":\"#Reference<.+>\"}/
  end

  test "it can encode tuples" do
    assert {:ok, ~s({"tuple":"{:test, 1, #PID<0.250.0>}"})} ==
             Ink.Encoder.encode(%{tuple: {:test, 1, :c.pid(0, 250, 0)}})
  end

  test "it can encode functions" do
    {:ok, result} = Ink.Encoder.encode(%{fun: fn -> nil end})
    assert result =~ ~r/#Function/
  end

  test "it recursively encodes maps" do
    assert {:ok, ~s({"stuff":{"pid":"#PID<0.250.0>"}})} ==
             Ink.Encoder.encode(%{stuff: %{pid: :c.pid(0, 250, 0)}})
  end

  test "it recursively encodes struct" do
    assert {:ok, ~s({"field":{"pid":"#PID<0.250.0>"}})} ==
             Ink.Encoder.encode(%TestStruct{field: %{pid: :c.pid(0, 250, 0)}})
  end

  test "it encodes map keys" do
    assert {:ok, ~s({"#PID<0.250.0>":1})} ==
             Ink.Encoder.encode(%{:c.pid(0, 250, 0) => 1})
  end

  test "it recursively encodes lists" do
    assert {:ok, ~s({"data":[1,2,[3,"#PID<0.250.0>"]]})} ==
             Ink.Encoder.encode(%{data: [1, 2, [3, :c.pid(0, 250, 0)]]})
  end
end
