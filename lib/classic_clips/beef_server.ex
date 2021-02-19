defmodule ClassicClips.BeefServer do
  use GenServer

  alias ClassicClips.BigBeef

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{games: []}, name: MyBeef)
  end

  def get_active_game_count() do
    GenServer.call(MyBeef, :get_active_game_count)
  end

  @impl true
  def init(state) do
    games = fetch_beef_data(state)
    :timer.send_interval(45_000, :work)
    {:ok, %{games: games}}
  end

  @impl true
  def handle_info(:work, state) do
    games = fetch_beef_data(state) |> IO.inspect
    IO.puts "saving #{Enum.count(games)} games"
    {:noreply, %{games: games}}
  end

  @impl true
  def handle_call(:get_active_game_count, _, %{games: games} = state) do
    count = Enum.count(games, fn {_, gst} ->
      {:ok, game_time, _} = DateTime.from_iso8601(gst)
      game_time < DateTime.utc_now()
    end)

    {:reply, count, state}
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

    Enum.filter(games, fn {game_id, _} ->
      new_game = Enum.find(new_games, fn {g_id, _, _} -> g_id == game_id end)
      case new_game do
        nil -> true
        {_, game_status, _} -> game_status != "Final"
      end
    end)
  end

  defp game_time?() do
    {:ok, game_time} = Time.from_iso8601("15:45:00.000000")
    {:ok, buzzer_time} = Time.from_iso8601("04:20:00.000000")

    current_time = DateTime.utc_now() |> DateTime.to_time()

    current_time > game_time or current_time < buzzer_time
  end
end
