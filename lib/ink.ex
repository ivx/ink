defmodule Ink do
  use GenEvent

  def init(__MODULE__) do
    {:ok, default_options()}
  end

  def handle_call({:configure, options}, state) do
    config = state
    |> Map.merge(Enum.into(options, %{}))
    |> update_secret_strings
    {:ok, :ok, config}
  end

  def handle_event({_, gl, {Logger, _, _, _}}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event({level, _, {Logger, message, timestamp, metadata}}, state) do
    log_message(message, level, timestamp, metadata, state)
    {:ok, state}
  end

  def log_message(message, level, timestamp, metadata, config) do
    if Logger.compare_levels(level, config.level) != :lt do
      message
      |> base_map(timestamp)
      |> Map.merge(Enum.into(metadata, %{}))
      |> Poison.encode
      |> log_json(config)
    end
  end

  defp log_json({:ok, json}, config) do
    json
    |> filter_secret_strings(config.secret_strings)
    |> log_to_device(config.io_device)
  end
  defp log_json(other, config) do
    if Mix.env == :dev, do: log_to_device(inspect(other), config.io_device)
  end

  defp log_to_device(msg, io_device), do: IO.puts(io_device, msg)

  defp base_map(message, timestamp) when is_binary(message) do
    %{message: message, timestamp: formatted_timestamp(timestamp)}
  end
  defp base_map(message, timestamp) do
    %{message: inspect(message), timestamp: formatted_timestamp(timestamp)}
  end

  defp formatted_timestamp({date, {hours, minutes, seconds, microseconds}}) do
    {date, {hours, minutes, seconds}}
    |> NaiveDateTime.from_erl!({microseconds, 3})
    |> NaiveDateTime.to_iso8601
  end

  defp update_secret_strings(config) do
    uri_credentials = Enum.flat_map(config.filtered_uri_credentials, fn uri ->
      uri |> URI.parse |> Map.get(:userinfo) |> String.split(":")
    end)
    Map.put(config, :secret_strings, config.filtered_strings ++ uri_credentials)
  end

  defp filter_secret_strings(message, secret_strings) do
    Enum.reduce(secret_strings, message, fn secret, msg ->
      String.replace(msg, secret, "[FILTERED]")
    end)
  end

  defp default_options do
    %{
      level: :debug,
      filtered_strings: [],
      filtered_uri_credentials: [],
      secret_strings: [],
      io_device: :stdio
    }
    |> Map.merge(Enum.into(Application.get_env(:logger, Ink, []), %{}))
  end
end
