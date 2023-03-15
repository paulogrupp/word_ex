defmodule WordEx.Type do
  @type game_state :: :game_start | :won | :lost | :good_guess | :bad_guess | :already_guessed
  @type guess_letters_state :: :correct | :misplaced | :wrong
  @type last_attempt_result :: %{String.t() => guess_letters_state}
  @type tally :: %{
          turns_left: integer,
          game_state: state,
          letters: list(String.t()),
          last_attempt_result: last_attempt_result
        }
end
