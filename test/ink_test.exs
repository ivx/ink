defmodule InkTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  defp default_config do
    %{level: :info, filtered_strings: ["SECRET"]}
  end

  setup do
    {:ok, %{timestamp: {{2017, 2, 1}, {4, 3, 2, 5123}}}}
  end

  test "it can be configured" do
    Logger.configure_backend(Ink, [test: :moep])
  end

  test "it logs a message", %{timestamp: timestamp} do
    msg = capture_io(fn ->
      Ink.log_message("test", :info, timestamp, [], default_config())
    end)

    assert Poison.decode!(msg) == %{
      "timestamp" => "2017-02-01T04:03:02.005",
      "message" => "test"}
  end

  test "it doesn't JSON encode the message", %{timestamp: timestamp} do
    msg = capture_io(fn ->
      Ink.log_message([1 | 2], :info, timestamp, [], default_config())
    end)

    assert Poison.decode!(msg) == %{
      "timestamp" => "2017-02-01T04:03:02.005",
      "message" => "[1 | 2]"}
  end

  test "it includes metadata", %{timestamp: timestamp} do
    msg = capture_io(fn ->
      Ink.log_message("test", :info, timestamp, [moep: "hi"], default_config())
    end)

    assert Poison.decode!(msg) == %{
      "timestamp" => "2017-02-01T04:03:02.005",
      "message" => "test",
      "moep" => "hi"}
  end

  test "respects log level", %{timestamp: timestamp} do
    msg = capture_io(fn ->
      Ink.log_message(
        "test",
        :info,
        timestamp,
        [moep: "hi"],
        Map.put(default_config(), :level, :warn))
    end)

    assert msg == ""
  end

  test "it filters secret strings", %{timestamp: timestamp} do
    msg = capture_io(fn ->
      Ink.log_message(
        "this is a SECRET string",
        :info,
        timestamp,
        [moep: "hi"],
        default_config())
    end)

    assert Poison.decode!(msg) == %{
      "message" => "this is a [FILTERED] string",
      "moep" => "hi",
      "timestamp" => "2017-02-01T04:03:02.005"}
  end
end
