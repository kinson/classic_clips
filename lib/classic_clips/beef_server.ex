defmodule ClassicClips.BeefServer do
  use GenServer

  alias ClassicClips.{BigBeef, GameData}

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{games: []}, name: MyBeef)
  end

  def get_active_game_count() do
    GenServer.call(MyBeef, :get_active_game_count)
  end

  @impl true
  def init(state) do
    games = fetch_beef_data(state)
    :timer.send_interval(50_000, :work)
    {:ok, %{games: games}}
  end

  @impl true
  def handle_info(:work, state) do
    games = fetch_beef_data(state)
    {:noreply, %{games: games}}
  end

  @impl true
  def handle_call(:get_active_game_count, _, %{games: games} = state) do
    count =
      Enum.count(games, &GameData.is_game_active?/1)

    {:reply, count, state}
  end

  # every minute
  # are there games in the state, if so, do nothing, if not, try to fetch them
  # for each game in state, if the game has started, fetch box score info and save it
  # if one of the games is finished, remove it from state

  defp fetch_beef_data(%{games: []}) do
    # only fetch games if it is game time
    case game_time?() do
      true ->
        BigBeef.Services.Stats.games_or_someshit()
        |> Enum.filter(&GameData.should_keep_game_on_active_list?/1)
        |> IO.inspect()

      false ->
        []
    end
  end

  defp fetch_beef_data(%{games: games}) do
    new_games = BigBeef.fetch_and_broadcast_games(games)

    update_game_data = make_update_game_data(new_games)

    Enum.map(games, update_game_data)
    |> Enum.map(&GameData.increment_fetch_count/1)
    |> Enum.filter(&GameData.should_keep_game_on_active_list?/1)
    |> IO.inspect()
  end

  defp game_time?() do
    {:ok, game_time} = Time.from_iso8601("16:15:00.000000")
    {:ok, buzzer_time} = Time.from_iso8601("04:31:00.000000")

    current_time = DateTime.utc_now() |> DateTime.to_time()

    games_have_started = first_is_after?(current_time, game_time)
    games_have_not_ended = first_is_after?(buzzer_time, current_time)

    games_have_started or games_have_not_ended
  end

  defp first_is_after?(d1, d2) do
    Time.compare(d1, d2) == :gt
  end

  defp make_update_game_data(new_games) do
    fn %GameData{id: id} = gd ->
      case Enum.find(new_games, fn %GameData{id: g_id} -> g_id == id end) do
        nil -> gd
        %GameData{status: new_status} -> %GameData{gd | status: new_status}
      end
    end
  end
end
