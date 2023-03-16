defmodule WordEx.Impl.Game do
  alias WordEx.Type
  alias Unicode.Transform.LatinAscii, as: AsciiConverter

  @default_word_length 5
  @type t :: %__MODULE__{
          turns_left: integer,
          game_state: Type.game_state(),
          letters: list(String.t()),
          normalized_letters: list(String.t()),
          last_attempt: list(String.t())
        }

  defstruct(
    turns_left: 6,
    game_state: :game_start,
    letters: [],
    normalized_letters: [],
    last_attempt: []
  )

  def new_game do
    Dictionary.random_word(@default_word_length) |> new_game()
  end

  def new_game(word) do
    %__MODULE__{
      letters: word |> generate_codepoints(),
      normalized_letters: word |> AsciiConverter.transform() |> generate_codepoints()
    }
  end

  @spec make_guess(t, String.t()) :: {t, Type.tally()}
  def make_guess(game = %{game_state: state}, _guess)
      when state in [:won, :lost] do
    game
    |> return_with_tally
  end

  def make_guess(game, guess) do
    guess =
      AsciiConverter.transform(guess)
      |> String.downcase()
      |> String.codepoints()

    game
    |> accept_guess(
      guess,
      valid_word?(Enum.join(guess))
    )
    |> return_with_tally
  end

  ####################################################################################

  defp accept_guess(game, _guess, _valid_word = false) do
    %{game | game_state: :invalid_input}
  end

  defp accept_guess(game, guess, _valid_word) do
    game |> score_guess(guess)
  end

  ####################################################################################

  # defp score_guess(game, _good_guess = true) do
  #   new_state = maybe_won(MapSet.subset?(MapSet.new(game.normalized_letters), game.used))
  #   %{game | game_state: new_state}
  # end

  defp score_guess(game, guess) do
    %{game | turns_left: game.turns_left - 1, last_attempt: guess}
  end

  ####################################################################################

  def tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      letters: game.letters
      # last_attempt_result: score_last_attempt(game)
    }
  end

  defp return_with_tally(game) do
    {game, tally(game)}
  end

  def reveal_guessed_letters(game = %{game_state: :lost}) do
    game.letters
  end

  def reveal_guessed_letters(game) do
    game.letters
    |> Enum.map(fn letter ->
      MapSet.member?(game.used, AsciiConverter.transform(letter))
      |> maybe_reveal(letter)
    end)
  end

  def generate_codepoints(string) do
    string |> String.downcase() |> String.codepoints()
  end

  def maybe_reveal(true, letter), do: letter
  def maybe_reveal(_, _), do: "_"

  defp maybe_won(true), do: :won

  defp maybe_won(_), do: :good_guess

  defp valid_word?(word) do
    WordEx.word_exists?(word)
  end

  defp score_letters(word, guess) do
    score = []

    Enum.map(guess, fn letter ->
      if Enum.member?(word, letter), do: "right", else: "wrong"
    end)

    score
  end
end
