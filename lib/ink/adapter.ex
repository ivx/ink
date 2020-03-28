defmodule Ink.Adapter do
  @moduledoc """
  Adapter behaviours
  """

  @type socket :: String.t()
  @type host :: String.t()
  @type msg :: String.t()

  @doc """
  Adaptor's sending function for log.
  """
  @callback send(socket, host, port, msg) :: :ok | {:error, any}

  defmacro __using__(_) do
    quote location: :keep do
      import Ink.Adapter
    end
  end
end
