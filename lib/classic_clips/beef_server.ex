defmodule ClassicClips.BeefServer do
  use GenServer

  alias ClassicClips.BigBeef

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{games: []})
  end

  @impl true
  def init(state) do
    :timer.send_interval(60_000, :work)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    games = fetch_beef_data(state)
    {:noreply, %{games: games}}
  end

  # every minute
  # are there games in the state, if so, do nothing, if not, try to fetch them
  # for each game in state, if the game has started, fetch box score info and save it
  # if one of the games is finished, remove it from state

  defp fetch_beef_data(%{games: []}) do
    # only fetch games if it is game time
    BigBeef.Services.Stats.games_or_someshit()
  end

  defp fetch_beef_data(%{games: games}) do
    new_games = BigBeef.fetch_and_broadcast_games(games)

    Enum.filter(new_games, fn {_, game_status, _} ->
      game_status != "Final"
    end)
    |> Enum.map(fn {game_id, _, game_start_time} -> {game_id, game_start_time} end)
    |> IO.inspect()
  end
end
