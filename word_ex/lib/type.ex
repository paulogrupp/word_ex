defmodule WordEx.Type do
  @type game_state :: :game_start | :won | :lost | :guess_evaluated | :invalid_input
  @type guess_letters_state :: :correct | :misplaced | :wrong
  @type last_attempt_result :: %{String.t() => guess_letters_state}
  @type tally :: %{
          turns_left: integer,
          game_state: game_state,
          letters: list(String.t()),
          last_attempt_result: last_attempt_result
        }
end
