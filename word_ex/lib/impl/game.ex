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

  defdelegate word_exists?(word), to: WordEx.Runtime.WordHandler.Server

  def new_game do
    Dictionary.random_word(@default_word_length) |> new_game()
  end

  def new_game(word) do
    %__MODULE__{
      letters: word |> generate_codepoints(),
      normalized_letters: word |> AsciiConverter.transform() |> generate_codepoints()
    }
  end

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
    %{game | last_attempt: guess} |> score_guess(evaluate_guess(game, guess))
  end

  ####################################################################################

  defp score_guess(game, [:correct]) do
    %{game | game_state: :won}
  end

  defp score_guess(game = %{turns_left: 1}, _evaluation) do
    %{game | game_state: :lost, turns_left: 0}
  end

  defp score_guess(game, _evaluation) do
    %{game | game_state: :guess_evaluated, turns_left: game.turns_left - 1}
  end

  ####################################################################################

  def tally(game) do
    %{
      turns_left: game.turns_left,
      game_state: game.game_state,
      last_attempt_result: score_letters(game.last_attempt, game.letters)
    }
  end

  defp return_with_tally(game), do: {game, tally(game)}

  def reveal_guessed_letters(game = %{game_state: :lost}), do: game.letters

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

  def evaluate_guess(game, guess) do
    Enum.uniq(score_letters(guess, game.letters))
  end

  defp valid_word?(word), do: word_exists?(word)

  def score_letters([], _), do: []

  def score_letters(guess, solution) do
    solution_chars_taken = compare_correct_cases(guess, solution)
    {guess, solution} = strip_correct_cases(guess, solution, solution_chars_taken)
    present_cases = Enum.reverse(strip_present_cases(guess, solution))
    compare_absency_and_position(solution, present_cases)
  end

  def compare_absency_and_position(solution, present_cases) do
    Enum.zip([solution, present_cases])
    |> Enum.map(fn
      {nil, _} -> :correct
      {_, nil} -> :wrong
      {_, _} -> :misplaced
    end)
  end

  def compare_correct_cases(guess, solution) do
    Enum.zip(guess, solution)
    |> Enum.map(fn {guess_letter, solution_letter} ->
      guess_letter == solution_letter
    end)
  end

  def strip_correct_cases(guess, solution, taken_cases) do
    Enum.zip([guess, solution, taken_cases])
    |> Enum.map(fn
      {_, _, true} -> {nil, nil}
      {guess_letter, solution_letter, _} -> {guess_letter, solution_letter}
    end)
    |> Enum.unzip()
  end

  def strip_present_cases(guess, solution), do: strip_present_cases(guess, solution, [])

  def strip_present_cases([guess_letter | guess], solution, indexes) do
    found =
      Enum.find_index(solution, fn
        solution_letter -> !is_nil(solution_letter) && solution_letter == guess_letter
      end)

    solution = strip_solution_by_index(found, solution)
    indexes = [found | indexes]
    strip_present_cases(guess, solution, indexes)
  end

  def strip_present_cases([], _, indexes), do: indexes

  def strip_solution_by_index(nil, solution), do: solution

  def strip_solution_by_index(index, solution), do: List.replace_at(solution, index, nil)
end
