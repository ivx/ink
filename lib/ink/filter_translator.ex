defmodule Ink.FilterTranslator do
  def translate(_, _, :report, _), do: :skip
  def translate(min_level, level, kind, message) do
    Logger.Translator.translate(min_level, level, kind, message)
  end
end
