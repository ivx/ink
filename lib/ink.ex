defmodule Ink do
  @moduledoc """
  A backend for the Elixir `Logger` that logs JSON and filters your secrets.

  ## Usage

  To use `Ink` for your logging, just configure it as a backend:

      config :logger, backends: [Ink]

      # optional additional configuration
      config :logger, Ink,
        name: "your app",
        level: :info

  ### Options

  In total, the following options are supported by `Ink`:

  - `:name` the name of your app that will be added to all logs
  - `:io_device` the IO device the logs are written to (default: `:stdio`)
  - `:level` the minimum log level for outputting messages (default: `:debug`)
  - `:filtered_strings` secret strings that should not be printed in logs
  (default: `[]`)
  - `:filtered_uri_credentials` URIs that contain credentials for filtering
  (default: `[]`)
  - `:metadata` the metadata keys that should be included in the logs (default:
  all)
   - `:exclude_hostname` exclude local `hostname` from the log (default:
  false)

  ### Filtering secrets

  `Ink` can be configured to filter secrets out of your logs:

      config :logger, Ink,
        filtered_strings: ["password"]

  Sometimes, you configure a connection using a URL. For example, a RabbitMQ
  connection could be configured with the URL
  `"amqp://user:password@localhost:5672"`. Filtering the whole URL from your
  logs doesn't do you any good. Therefore, `Ink` has a separate option to pass
  secret URLs:

      config :logger, Ink,
        filtered_uri_credentials: ["amqp://user:password@localhost:5672"]

  This code will parse the URL and only filter `"password"` from your logs.

  #### Preventing reports on the terminal

  When processes crash - which is a normal thing to happen in Elixir - OTP sends
  reports to the handlers of the `:error_logger`. In some environments, there is
  a default handler that prints these to the terminal. Since it includes the
  state of the crashed process, this can include secrets from your application.
  `Ink` is unable to filter these reports, because they are not printed using
  the `Logger`.

  You can disable printing of these reports with the following line in your
  config:

      config :sasl, sasl_error_logger: false

  ### Metadata

  If you don't configure any specific metadata, `Ink` will include all metadata
  as separate fields in the logged JSON. If you only want to include specific
  metadata in your logs, you need to configure the included fields.

      config :logger, Ink,
        metadata: [:pid, :my_field]

  *Note*: Since the term PID is also prevalent in the UNIX world, services like
   LogStash expect an integer if they encounter a field named `pid`. Therefore,
   `Ink` will log the PID as `erlang_pid`.

  ### Add backend integration

  #### Available backends

  - Logstash  

  Config:  

      config :logger, Ink,
        adapters: [
          {
            Ink.Adapter.Logtash, 
            config: %{
              host: "127.0.0.1",
              port: 10001
            }
          } 
        ]
  """

  @behaviour :gen_event

  def init(__MODULE__) do
    {:ok, configure(Application.get_env(:logger, Ink, []), default_options())}
  end

  def handle_call({:configure, options}, state) do
    {:ok, :ok, configure(options, state)}
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

  def handle_info(_msg, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def code_change(_old, state, _extra) do
    {:ok, state}
  end

  defp configure(options, state) do
    Map.merge(state, Enum.into(options, %{}))
    |> update_secret_strings()
    |> update_adapters()
  end

  defp update_adapters(options) do
    Map.put(options, :adapters, configure_adapters(options.adapters))
  end

  defp configure_adapters([head | tail]) do
    {module, attrs} = head

    config = Keyword.get(attrs, :config)
    host = Map.get(config, :host, nil)
    port = Map.get(config, :port, nil)
    type = module.connection_type()
    
    cond do
      is_nil(host) or is_nil(port) or is_nil(type) ->
        configure_adapters(tail)
      !is_integer(port) ->
        configure_adapters(tail)
      !is_atom(type) ->
        configure_adapters(tail)
      true ->
        config = %{
          module: module,
          host: host,
          port: port,
          socket: nil
        }

        case type do
          :udp ->
            {:ok, socket} = :gen_udp.open(0)

            [Map.put(config, :socket, socket) | configure_adapters(tail)]
          _ ->
            configure_adapters(tail)
        end
    end
  end

  defp configure_adapters([]) do
    []
  end

  defp log_message(message, level, timestamp, metadata, config) do
    if Logger.compare_levels(level, config.level) != :lt do
      message
      |> base_map(timestamp, level, config)
      |> Map.merge(process_metadata(metadata, config))
      |> Ink.Encoder.encode()
      |> log_json(config)
    end
  end

  defp process_metadata(metadata, config) do
    metadata
    |> filter_metadata(config)
    |> rename_metadata_fields
    |> Enum.into(%{})
    |> Map.delete(:time)
  end

  defp filter_metadata(metadata, %{metadata: nil}), do: metadata

  defp filter_metadata(metadata, config) do
    metadata |> Enum.filter(fn {key, _} -> key in config.metadata end)
  end

  defp rename_metadata_fields(metadata) do
    metadata
    |> Enum.map(fn
      {:pid, value} -> {:erlang_pid, value}
      other -> other
    end)
  end

  defp log_json({:ok, json}, config) do
    cond do
      Enum.count(config.adapters) > 0 ->
        log_to_adapters(
          config[:adapters], 
          filter_secret_strings(json, config.secret_strings)
        )
      true ->
        log_to_device(
          filter_secret_strings(json, config.secret_strings), 
          config.io_device
        )
    end
  end

  defp log_json(other, config) do
    if Mix.env() == :dev, do: log_to_device(inspect(other), config.io_device)
  end

  defp log_to_device(msg, io_device), do: IO.puts(io_device, msg)

  defp log_to_adapters([head | tail], msg) do
    head.module.send(head.socket, head.host, head.port, msg)
    log_to_adapters(tail, msg)
  end

  defp log_to_adapters([], _) do
    :ok
  end

  defp base_map(message, timestamp, level, %{exclude_hostname: true} = _config)
       when is_binary(message) do
    %{
      name: name(),
      pid: System.get_pid() |> String.to_integer(),
      msg: message,
      time: formatted_timestamp(timestamp),
      level: level(level),
      v: 0
    }
  end

  defp base_map(message, timestamp, level, _) when is_binary(message) do
    %{
      name: name(),
      pid: System.get_pid() |> String.to_integer(),
      hostname: hostname(),
      msg: message,
      time: formatted_timestamp(timestamp),
      level: level(level),
      v: 0
    }
  end

  defp base_map(message, timestamp, level, config) when is_list(message) do
    base_map(IO.iodata_to_binary(message), timestamp, level, config)
  end

  defp formatted_timestamp({date, {hours, minutes, seconds, milliseconds}}) do
    {date, {hours, minutes, seconds}}
    |> NaiveDateTime.from_erl!({milliseconds * 1000, 3})
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.to_iso8601()
  end

  defp update_secret_strings(config) do
    secret_strings =
      config.filtered_strings
      |> Kernel.++(uri_credentials(config.filtered_uri_credentials))
      |> Enum.reject(fn s -> s == "" || is_nil(s) end)

    Map.put(config, :secret_strings, secret_strings)
  end

  defp uri_credentials(uris) do
    uris
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn uri -> uri |> URI.parse() |> Map.get(:userinfo) end)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(fn userinfo -> userinfo |> String.split(":") |> List.last() end)
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
      io_device: :stdio,
      metadata: nil,
      adapters: []
    }
  end

  defp level(level) do
    case level do
      :debug -> 20
      :info -> 30
      :warn -> 40
      :error -> 50
    end
  end

  defp hostname do
    with {:ok, hostname} <- :inet.gethostname(), do: List.to_string(hostname)
  end

  defp name do
    :logger
    |> Application.get_env(Ink)
    |> Keyword.fetch!(:name)
  end
end
