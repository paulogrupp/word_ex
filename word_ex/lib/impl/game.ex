defmodule WordEx.Impl.Game do
  # alias Hangman.Type
  alias Unicode.Transform.LatinAscii, as: AsciiConverter

  @type t :: %__MODULE__{
          turns_left: integer,
          game_state: Type.game_state(),
          letters: list(String.t()),
          normalized_letters: list(String.t())
        }

  defstruct(
    turns_left: 6,
    game_state: :game_start,
    letters: [],
    normalized_letters: []
  )

  def new_game do
    Dictionary.random_word(5) |> new_game()
  end

  def new_game(word) do
    %__MODULE__{
      letters: word |> generate_codepoints(),
      normalized_letters: word |> AsciiConverter.transform() |> generate_codepoints()
    }
  end

  defp generate_codepoints(string) do
    string |> String.downcase() |> String.codepoints()
  end
end
