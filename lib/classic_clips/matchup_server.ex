defmodule ClassicClips.MatchupServer do
  use GenServer

  require Logger

  alias ClassicClips.PickEm
  alias ClassicClips.PickEm.MatchUp

  @interval :timer.minutes(2)
  @long_interval :timer.minutes(30)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Logger.notice("Starting #{__MODULE__}")
    {:ok, Map.put(state, :matchup, nil), @interval}
  end

  @impl true
  def handle_info(:timeout, %{matchup: nil} = state) do
    # query for matchup in db 
    case PickEm.get_current_matchup() do
      nil ->
        Logger.notice("No matchup to monitor")
        {:noreply, state, @long_interval}

      %MatchUp{winning_team_id: wti} when not is_nil(wti) ->
        Logger.notice("No active matchup to monitor")
        {:noreply, state, @long_interval}

      matchup ->
        %{away_team: away_team, home_team: home_team} = matchup

        Logger.notice(
          "Found new matchup to watch: #{away_team.abbreviation} @ #{home_team.abbreviation}"
        )

        {:noreply, Map.put(state, :matchup, matchup), @interval}
    end
  end

  def handle_info(:timeout, %{matchup: %MatchUp{winning_team_id: nil} = matchup} = state) do
    two_hours_ago = -1 * 60 * 60 * 2
    lower_date_limit = DateTime.utc_now() |> DateTime.add(two_hours_ago)

    # don't check on games that started less than two hours ago
    if DateTime.compare(matchup.tip_datetime, lower_date_limit) == :lt do
      Logger.notice("Fetching matchup data from nba")
      matchup = check_game_data(matchup)
      {:noreply, %{state | matchup: matchup}, @interval}
    else
      Logger.notice(
        "Too early to check game data, checking in #{DateTime.diff(matchup.tip_datetime, lower_date_limit)} seconds"
      )

      {:noreply, state, @interval}
    end
  end

  def handle_info(:timeout, %{matchup: %MatchUp{winning_team_id: _} = matchup} = state) do
    %{away_team: away_team, home_team: home_team} = matchup

    Logger.notice(
      "Matchup complete, waiting for new matchup #{away_team.abbreviation} @ #{home_team.abbreviation}"
    )

    {:noreply, %{state | matchup: nil}, @long_interval}
  end

  def handle_info(:timeout, state) do
    Logger.notice("Nothing to do in #{__MODULE__}")
    # no game to look forward to
    {:noreply, state, @long_interval}
  end

  defp check_game_data(matchup) do
    game_data = get_game_data(matchup.nba_game_id)

    case game_data.game_status do
      "Final" ->
        NewRelic.Instrumented.Task.start_link(fn ->
          ClassicClips.PickEm.update_user_picks_with_matchup_result(game_data, matchup)
          ClassicClips.PickEm.update_ndc_records_with_matchup_result(game_data, matchup)
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
