defmodule WordEx.Impl.WordHandler do
  alias Unicode.Transform.LatinAscii, as: AsciiConverter
  @default_word_length 5

  def word_list_hash() do
    Dictionary.word_list(@default_word_length)
    |> Enum.reduce(%{}, fn word, acc ->
      Map.put(acc, AsciiConverter.transform(word), word)
    end)
  end

  def word_exists?(word_list_hash, word) do
    !is_nil(Map.get(word_list_hash, AsciiConverter.transform(word)))
  end
end
