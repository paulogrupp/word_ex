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

  @spec tally(
          atom
          | %{:game_state => any, :letters => any, :turns_left => any, optional(any) => any}
        ) :: %{game_state: any, letters: any, turns_left: any}
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

  def score_letters(guess, word) do
    solution_chars_taken = compare_correct_cases(guess, word)
    should_absent_indexes = handle_taken_cases(guess, word, solution_chars_taken)
    WordEx.Impl.Game.compare_absency_and_position(should_absent_indexes, guess, word)
  end

  def compare_absency_and_position(should_absent_indexes, guess, solution) do
    Enum.zip([guess, solution, should_absent_indexes])
    |> Enum.map(fn {guess_letter, solution_letter, absent_index} ->
      {guess_letter == solution_letter, Enum.member?(solution, guess_letter),
       is_nil(absent_index)}
    end)
    |> Enum.map(fn
      {true, _, _} -> "correct"
      {_, false, _} -> "absent"
      {_, true, true} -> "present"
      {_, _, false} -> "absent"
    end)
  end

  def compare_correct_cases(guess, solution) do
    Enum.zip(guess, solution)
    |> Enum.map(fn {guess_letter, solution_letter} ->
      guess_letter == solution_letter
    end)
  end

  def handle_taken_cases(guess, solution, solution_chars_taken) do
    Enum.with_index(guess, fn guess_letter, guess_index ->
      Enum.with_index(solution, fn solution_letter, solution_index ->
        {solution_letter, solution_index}
      end)
      |> Enum.find_index(fn {solution_letter, solution_index} ->
        guess_letter == solution_letter && Enum.at(solution_chars_taken, solution_index) &&
          solution_index != guess_index
      end)
    end)
  end
end
