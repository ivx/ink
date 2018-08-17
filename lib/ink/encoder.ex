defmodule Ink.Encoder do
  def encode(map) do
    map
    |> encode_value
    |> Poison.encode()
  end

  defp encode_value(value)
       when is_pid(value) or is_port(value) or is_reference(value) or
              is_tuple(value) or is_function(value),
       do: inspect(value)

  defp encode_value(%{__struct__: _} = value) do
    value
    |> Map.from_struct()
    |> encode_value
  end

  defp encode_value(value) when is_map(value) do
    Enum.into(value, %{}, fn {k, v} ->
      {encode_value(k), encode_value(v)}
    end)
  end

  defp encode_value(value) when is_list(value),
    do: Enum.map(value, &encode_value/1)

  defp encode_value(value), do: value
end
