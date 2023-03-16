defmodule WordEx do
  alias WordEx.Impl.Game

  defdelegate new_game, to: Game
  defdelegate make_guess(game, guess), to: Game
  defdelegate word_exists?(word), to: WordEx.Runtime.WordHandler.Server
end
