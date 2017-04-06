defmodule InkTest do
  use ExUnit.Case, async: false

  require Logger

  setup do
    {:ok, _} = Logger.add_backend(Ink)
    Logger.configure_backend(Ink, io_device: self())
    on_exit fn ->
      Logger.flush
      Logger.remove_backend(Ink)
    end
  end

  test "it can be configured" do
    Logger.configure_backend(Ink, test: :moep)
  end

  test "it logs a message" do
    Logger.info("test")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    assert %{"message" => "test", "timestamp" => timestamp} = Poison.decode!(msg)
    assert {:ok, _} = NaiveDateTime.from_iso8601(timestamp)
  end

  test "it includes metadata" do
    Logger.metadata(test: 1)
    Logger.info("test")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    assert %{"test" => 1} = Poison.decode!(msg)
  end

  test "respects log level" do
    Logger.configure_backend(Ink, level: :warn)
    Logger.info("test")

    refute_receive {:io_request, _, _, {:put_chars, :unicode, _}}
  end

  test "it filters secret strings" do
    Logger.configure_backend(Ink, filtered_strings: ["SECRET"])
    Logger.info("this is a SECRET string")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    assert %{"message" => "this is a [FILTERED] string"} = Poison.decode!(msg)
  end

  test "it filters URI credentials" do
    Logger.configure_backend(
      Ink, filtered_uri_credentials: ["amqp://guest:password@localhost:5672"])
    Logger.info("the credentials from your URI are guest and password")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    assert %{
      "message" => "the credentials from your URI are [FILTERED] and [FILTERED]"
    } = Poison.decode!(msg)
  end
end
