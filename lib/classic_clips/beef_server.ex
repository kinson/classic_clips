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
    games = fetch_beef_data(state) |> IO.inspect
    IO.puts "saving #{Enum.count(games)} games"
    {:noreply, %{games: games}}
  end

  # every minute
  # are there games in the state, if so, do nothing, if not, try to fetch them
  # for each game in state, if the game has started, fetch box score info and save it
  # if one of the games is finished, remove it from state

  defp fetch_beef_data(%{games: []}) do
    # only fetch games if it is game time
    case game_time?() do
      true -> BigBeef.Services.Stats.games_or_someshit()
      false -> []
    end
  end

  defp fetch_beef_data(%{games: games}) do
    new_games = BigBeef.fetch_and_broadcast_games(games)

    Enum.filter(new_games, fn {_, game_status, _} ->
      game_status != "Final"
    end)
    |> Enum.map(fn {game_id, _, game_start_time} -> {game_id, game_start_time} end)
  end

  defp game_time?() do
    {:ok, game_time} = Time.from_iso8601("15:45:00.000000")
    {:ok, buzzer_time} = Time.from_iso8601("04:20:00.000000")

    current_time = DateTime.utc_now() |> DateTime.to_time()

    current_time > game_time or current_time < buzzer_time
  end
end
