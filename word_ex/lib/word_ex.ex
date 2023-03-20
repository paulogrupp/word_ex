defmodule WordEx do
  alias WordEx.Runtime.Server
  alias WordEx.Type

  @opaque game :: Server.t()
  @type tally :: Type.tally()

  @spec new_game :: game
  def new_game do
    {:ok, pid} = WordEx.Runtime.Application.start_game()
    pid
  end

  @spec make_guess(game, String.t()) :: tally
  def make_guess(game, guess) do
    GenServer.call(game, {:make_guess, guess})
  end

  @spec tally(game) :: tally
  def tally(game) do
    GenServer.call(game, {:tally})
  end
end
