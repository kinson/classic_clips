defmodule ClassicClips.MatchupServer do
  use GenServer

  @interval :timer.minutes(15)

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
    {:ok, state}
  end

  def handle_info(:timeout, %{matchup: matchup} = state) do
    # query game data from NBA
    game_data = get_game_data(matchup.nba_game_id)

    case game_data.status do
      "final" ->
        Task.start_link(fn ->
          ClassicClips.PickEm.update_user_picks_with_matchup_result(matchup, game_data)
        end)

        {:ok, Map.put(state, :matchup, nil)}

      _ ->
        {:ok, state}
    end
  end

  defp get_game_data(nba_game_id) do
    # get game data from nba api

    alias ClassicClips.BigBeef.Services.Stats

    Stats.get_boxscore_for_game(nba_game_id)
    |> Stats.extract_team_stats()

    # |> IO.inspect()
  end
end
