defmodule WordEx do
  alias WordEx.Impl.Game

  defdelegate new_game, to: Game
  defdelegate make_guess(game, guess), to: Game
end
