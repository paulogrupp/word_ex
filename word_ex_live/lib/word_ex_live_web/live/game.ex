defmodule WordExLiveWeb.Live.Game do
  use WordExLiveWeb, :live_view

  def mount(_params, _session, socket) do
    game = WordEx.new_game()
    tally = WordEx.tally(game)

    socket =
      socket
      |> assign(%{game: game, tally: tally, max_turns: tally.turns_left, letters_size: tally})

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="game-box">
    
    </div>
    """
  end
end
