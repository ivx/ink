defmodule Ink.Adapter do
  @moduledoc """
  Adapter behaviours
  """

  @type socket :: String.t()
  @type host :: String.t()
  @type msg :: String.t()
  @type connection_type :: Atom.t()

  @doc """
  Adaptor's sending function for log.
  """
  @callback send(socket, host, port, msg) :: :ok | {:error, any}

  @doc """
  Adapter connection type
  """
  @callback connection_type() :: connection_type

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour Ink.Adapter
    end
  end
end
