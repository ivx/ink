defmodule Ink.Adapter.Logstash do
  @moduledoc """
  Logstash Adapter for Ink

  Example Logstash Config:
  		input {
  		  udp {
  		    codec => json
  		    port => 10001
  		    queue_size => 10000
  		    workers => 10
  		    type => default_log_type
  		  }
  		}
  		output {
  		  stdout {}
  		  elasticsearch {
  		    protocol => http
  		  }
  		}
  """
  use Ink.Adapter

  @doc """
  Logstash connection type
  """
  @spec connection_type() :: Atom.t()
  def connection_type() do
    :udp
  end

  @doc """
  Losgtash send log message
  """
  @spec send(Port.t(), String.t(), Integer.t(), String.t()) ::
          :ok | {:error, any}
  def send(socket, host, port, msg) do
    :gen_udp.send(socket, to_charlist(host), port, to_charlist(msg))
  end
end
