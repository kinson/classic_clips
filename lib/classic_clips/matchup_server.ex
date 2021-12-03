defmodule ClassicClips.MatchupServer do
  use GenServer

  require Logger

  alias ClassicClips.PickEm
  alias ClassicClips.PickEm.MatchUp

  @interval :timer.minutes(2)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, Map.put(state, :matchup, nil), @interval}
  end

  @impl true
  def handle_info(:timeout, %{matchup: nil} = state) do
    # query for matchup in db 
    case PickEm.get_current_matchup() do
      nil ->
        Logger.notice("No matchup to monitor")
        {:noreply, state, @interval}

      matchup ->
        %{away_team: away_team, home_team: home_team} = matchup

        Logger.notice(
          "Found new matchup to watch: #{away_team.abbreviation} @ #{home_team.abbreviation}"
        )

        {:noreply, Map.put(state, :matchup, matchup), @interval}
    end
  end

  def handle_info(:timeout, %{matchup: %MatchUp{winning_team_id: nil} = matchup} = state) do
    IO.puts "made it maybe?"
    two_hours_ago = -1 * 60 * 60 * 2
    lower_date_limit = DateTime.utc_now() |> DateTime.add(two_hours_ago)

    # don't check on games that started less than two hours ago
    if matchup.tip_datetime < lower_date_limit do
      matchup = check_game_data(matchup)
      {:noreply, %{state | matchup: matchup}, @interval}
    else
      Logger.notice(
        "Too early to check game data, checking in #{DateTime.diff(matchup.tip_datetime, lower_date_limit)} seconds"
      )

      {:noreply, state, @interval}
    end
  end

  def handle_info(:timeout, state) do
    # no game to look forward to
    {:noreply, state, @interval}
  end

  defp check_game_data(matchup) do
    Logger.notice("Fetching matchup data from nba")
    game_data = get_game_data(matchup.nba_game_id)

    case game_data.game_status do
      "Final" ->
        Task.start_link(fn ->
          ClassicClips.PickEm.update_user_picks_with_matchup_result(game_data, matchup)
        end)

        nil

      _ ->
        Logger.notice("Matchup still in progress")
        matchup
    end
  end

  defp get_game_data(nba_game_id) do
    alias ClassicClips.BigBeef.Services.Stats

    case Stats.get_boxscore_for_game(nba_game_id) do
      {:ok, game} ->
        Stats.extract_team_stats(game)

      {:error, error} ->
        Logger.error("Could not fetch stats", error: error)
        %{game_status: "error"}
    end
  end
end
