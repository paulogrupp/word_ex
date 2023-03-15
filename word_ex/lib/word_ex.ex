defmodule WordEx do
  alias WordEx.Impl.Game

  defdelegate new_game, to: Game
end
