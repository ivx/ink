defmodule Ink.FilterTranslator do
  def translate(min_level, level, kind, message) do
    min_level
    |> Logger.Translator.translate(level, kind, message)
    |> filter_secret_strings
  end

  defp filter_secret_strings({:ok, message}) when is_list(message) do
    filter_secret_strings({:ok, IO.chardata_to_string(message)})
  end
  defp filter_secret_strings({:ok, message}) when is_binary(message) do
    {:ok, filter_secrets(message)}
  end
  defp filter_secret_strings(message), do: message

  defp filter_secrets(message) do
    Enum.reduce(secret_strings(), message, fn secret, msg ->
      String.replace(msg, secret, "[FILTERED]")
    end)
  end

  defp secret_strings do
    Application.get_env(:logger, Ink)
    |> Keyword.get(:filtered_strings, [])
    |> Enum.reject(fn s -> s == "" || is_nil(s) end)
  end
end
