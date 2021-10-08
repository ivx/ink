defmodule InkTest do
  use ExUnit.Case, async: false

  require Logger

  setup do
    {:ok, _} = Logger.add_backend(Ink)
    Logger.configure_backend(Ink, io_device: self())

    on_exit(fn ->
      Logger.flush()
      Logger.remove_backend(Ink)
    end)
  end

  test "it can be configured" do
    Logger.configure_backend(Ink, test: :moep)
  end

  test "it logs a message" do
    Logger.info("test")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}

    assert %{
             "name" => "ink",
             "hostname" => hostname,
             "pid" => pid,
             "msg" => "test",
             "time" => timestamp,
             "level" => 30,
             "v" => 0
           } = Jason.decode!(msg)

    assert is_binary(hostname)
    assert is_integer(pid)

    assert {:ok, _} = NaiveDateTime.from_iso8601(timestamp)
  end

  test "it logs an IO list" do
    Logger.info(["test", ["with", "list"]])

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    decoded_msg = Jason.decode!(msg)
    assert "testwithlist" == decoded_msg["msg"]
  end

  test "it includes an ISO 8601 timestamp" do
    Logger.info("test")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    assert %{"time" => timestamp} = Jason.decode!(msg)
    assert {:ok, _, 0} = DateTime.from_iso8601(timestamp)
    assert timestamp =~ ~r/\d\d\d\d-\d\d-\d\dT\d\d:\d\d:\d\d.\d\d\dZ/
  end

  test "it logs all metadata if not configured" do
    Logger.metadata(not_included: 1, included: 1)
    Logger.info("test")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    decoded_msg = Jason.decode!(msg)
    assert 1 == decoded_msg["not_included"]
    assert 1 == decoded_msg["included"]

    assert "test it logs all metadata if not configured/1" ==
             decoded_msg["function"]
  end

  test "it only includes configured metadata" do
    Logger.configure_backend(Ink, metadata: [:included])
    Logger.metadata(not_included: 1, included: 1)
    Logger.info("test")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    decoded_msg = Jason.decode!(msg)
    assert nil == decoded_msg["not_included"]
    assert 1 == decoded_msg["included"]
  end

  test "it exclude configured excluded_metadata" do
    Logger.configure_backend(Ink, exclude_metadata: [:not_included])
    Logger.metadata(included: 1, another_included: 1, not_included: 1)
    Logger.info("test")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    decoded_msg = Jason.decode!(msg)
    assert nil == decoded_msg["not_included"]
    assert 1 == decoded_msg["included"]
    assert 1 == decoded_msg["another_included"]
  end

  test "it puts the erlang process pid into erlang_pid" do
    Logger.info("test")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    decoded_msg = Jason.decode!(msg)
    assert inspect(self()) == decoded_msg["erlang_pid"]
  end

  test "respects log level" do
    Logger.configure_backend(Ink, level: :warn)
    Logger.info("test")

    refute_receive {:io_request, _, _, {:put_chars, :unicode, _}}
  end

  test "it respects status_mapping: :bunyan" do
    Logger.configure_backend(Ink, status_mapping: :bunyan)
    Logger.info("test")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    assert msg |> Jason.decode!() |> Map.fetch!("level") == 30
  end

  test "it respects status_mapping: :rfc5424" do
    Logger.configure_backend(Ink, status_mapping: :rfc5424)
    Logger.info("test")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    assert msg |> Jason.decode!() |> Map.fetch!("level") == 6
  end

  test "it filters preconfigured secret strings" do
    Logger.info("this is moep")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    assert %{"msg" => "this is [FILTERED]"} = Jason.decode!(msg)
  end

  test "it filters secret strings" do
    Logger.configure_backend(Ink, filtered_strings: ["SECRET", "", nil])
    Logger.info("this is a SECRET string")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    assert %{"msg" => "this is a [FILTERED] string"} = Jason.decode!(msg)
  end

  test "it filters URI credentials" do
    Logger.configure_backend(
      Ink,
      filtered_uri_credentials: [
        "amqp://guest:password@rabbitmq:5672",
        "redis://redis:6379/4",
        "",
        "blarg",
        nil
      ]
    )

    Logger.info("the credentials from your URI are guest and password")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}

    assert %{
             "msg" => "the credentials from your URI are guest and [FILTERED]"
           } = Jason.decode!(msg)
  end

  test "respects exclude hostname" do
    Logger.configure_backend(Ink, exclude_hostname: true)
    Logger.info("test")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}
    assert msg |> Jason.decode!() |> Map.get("hostname", :excluded) == :excluded
  end

  test "respects log_encoding_error: true" do
    Logger.configure_backend(Ink, log_encoding_error: true)
    Logger.info("\xFF")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, msg}}

    assert msg =~
             "{:error, %Jason.EncodeError{" <>
               "message: \"invalid byte 0xFF in <<255>>\"}}"
  end

  test "respects log_encoding_error: false" do
    Logger.configure_backend(Ink, log_encoding_error: false)
    Logger.info("\xFF")

    refute_receive {:io_request, _, _, {:put_chars, :unicode, _msg}}
  end

  test "defaults the behavior to log_encoding_error: true" do
    Logger.info("\xFF")

    assert_receive {:io_request, _, _, {:put_chars, :unicode, _msg}}
  end
end
