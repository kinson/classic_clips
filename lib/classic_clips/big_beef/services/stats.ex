defmodule ClassicClips.BigBeef.Services.Stats do
  @todays_games_url "https://cdn.nba.com/static/json/liveData/scoreboard/todaysScoreboard_00.json"

  @box_score_url "https://cdn.nba.com/static/json/liveData/boxscore/boxscore_"

  def get_todays_scoreboard() do
    with {:ok, %HTTPoison.Response{body: body}} = HTTPoison.get(@todays_games_url),
         {:ok, _} = response <- Jason.decode(body) do
      response
    else
      {:error, _} = error -> error
    end
  end

  def get_boxscore_for_game(game_id) do
    with {:ok, %HTTPoison.Response{body: body}} =
           get_box_score_url(game_id) |> HTTPoison.get(),
         {:ok, _} = response <- Jason.decode(body) do
      response
    else
      {:error, _} = error -> error
    end
  end

  def games_or_someshit() do
    case get_todays_scoreboard() do
      {:ok, games} -> extract_games(games)
      {:error, _} = error -> error
    end
  end

  defp get_box_score_url(game_id) do
    @box_score_url <> game_id <> ".json"
  end

  defp extract_games(%{"scoreboard" => %{"games" => games}}) do
    Enum.map(games, fn game ->
      Access.get(game, "gameId", nil)
    end)
  end

  defp extract_games(_), do: []

  def extract_player_stats(%{name: name, players: players}) do
    Enum.filter(players, fn %{"statistics" => %{"reboundsTotal" => rebounds}} ->
      rebounds >= 0
    end)
    |> Enum.map(fn player ->
      %{
        "personId" => person_id,
        "firstName" => first_name,
        "familyName" => last_name,
        "jerseyNum" => jersey_number,
        "statistics" => %{"reboundsTotal" => beef_count}
      } = player

      %{
        ext_person_id: "#{person_id}",
        first_name: first_name,
        last_name: last_name,
        number: String.to_integer(jersey_number),
        team: name,
        beef_count: beef_count
      }
    end)
  end

  def extract_team_stats(%{
        "game" => %{
          "homeTeam" => %{"players" => home_players, "teamName" => home_team_name},
          "awayTeam" => %{"players" => away_players, "teamName" => away_team_name},
          "period" => _period,
          "gameClock" => _game_clock
        }
      }) do
    %{
      home: %{name: home_team_name, players: home_players},
      away: %{name: away_team_name, players: away_players},
      game_time: 1140
    }
  end
end
