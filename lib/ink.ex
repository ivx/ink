defmodule Ink do
  use GenEvent

  @log_level_priorities %{debug: 0, info: 1, warn: 2, error: 3}

  def init(Ink) do
    {:ok, default_options()}
  end

  def handle_event({_, gl, {Logger, _, _, _}}, state) when node(gl) != node() do
    {:ok, state}
  end

  def handle_event(:flush, state) do
    {:ok, state}
  end

  def handle_event({:configure, options}, state) do
    {:ok, Map.merge(state, Enum.into(options, %{}))}
  end

  def handle_event({level, _, {Logger, message, timestamp, metadata}}, state) do
    log_message(message, level, timestamp, metadata, state)
    {:ok, state}
  end

  def log_message(message, level, timestamp, metadata, config) do
    if log_level?(level, config.level) do
      base_map(message, timestamp)
      |> Map.merge(Enum.into(metadata, %{}))
      |> Poison.encode!
      |> IO.puts
    end
  end

  defp base_map(message, timestamp) do
    %{message: message, timestamp: formatted_timestamp(timestamp)}
  end

  defp formatted_timestamp({date, {hours, minutes, seconds, microseconds}}) do
    {date, {hours, minutes, seconds}}
    |> NaiveDateTime.from_erl!({microseconds, 3})
    |> NaiveDateTime.to_iso8601
  end

  defp default_options do
    %{level: :debug}
  end

  defp log_level?(msg_level, config_level) do
    @log_level_priorities[msg_level] >= @log_level_priorities[config_level]
  end
end
