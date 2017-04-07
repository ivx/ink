defmodule Ink.FilterTranslatorTest do
  use ExUnit.Case, async: true

  test "it falls back to Logger.Translator" do
    assert :skip == Ink.FilterTranslator.translate(
      :debug, :info, :report, {:progress, ["this", ["is", "SECRET"]]})
  end

  test "it translates messages to filter secrets" do
    message = {'** Generic server MOEP', ["MOEP", {:msg, :moep}, %{}, :kapott]}
    assert :skip == Ink.FilterTranslator.translate(
      :debug, :error, :format, message)
  end
end
