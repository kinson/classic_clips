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
    with {:ok, %HTTPoison.Response{body: body}} = get_box_score_url(game_id) |> HTTPoison.get(),
         {:ok, _} = response <- Jason.decode(body) do
      response
    else
      {:error, _} = error -> IO.inspect(error)
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
    alias ClassicClips.GameData

    Enum.map(games, fn game ->
      {:ok, start_time, 0} =
        Access.get(game, "gameTimeUTC", nil)
        |> DateTime.from_iso8601()

      id = Access.get(game, "gameId", nil)

      status = Access.get(game, "gameStatusText", nil)

      %GameData{
        id: id,
        start_time: start_time,
        status: status
      }
    end)
  end

  defp extract_games(_), do: []

  def extract_player_stats(%{name: name, players: players}) do
    Enum.filter(players, fn %{"statistics" => %{"reboundsTotal" => rebounds}} ->
      rebounds > 5
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
          "period" => period,
          "gameClock" => game_clock,
          "gameStatusText" => game_status,
          "gameTimeUTC" => game_start_time,
          "gameId" => game_id
        }
      }) do
    %{
      home: %{name: home_team_name, players: home_players},
      away: %{name: away_team_name, players: away_players},
      game_status: game_status,
      game_time: parse_game_time(game_clock, period),
      game_start_time: game_start_time,
      game_id: game_id
    }
  end

  def parse_game_time(time, period) when period < 5 do
    # PT03M14.00S
    elapsed_period_time = get_seconds_left_in_period(time, 12)

    (period - 1) * 12 * 60 + elapsed_period_time
  end

  def parse_game_time(time, period) do
    elapsed_period_time = get_seconds_left_in_period(time, 5)

    regulation_duration = 48 * 60

    overtime_duration = (period - 5) * 5 * 60
    regulation_duration + overtime_duration + elapsed_period_time
  end

  def get_seconds_left_in_period(time, minutes_in_period) do
    minutes_left =
      String.split(time, "M")
      |> hd()
      |> String.replace("PT", "")
      |> String.to_integer()

    seconds_left =
      String.split(time, "M")
      |> Enum.at(1)
      |> String.split(".")
      |> hd()
      |> String.to_integer()

    minutes_elapsed = minutes_in_period - 1 - minutes_left
    seconds_elapsed = 60 - seconds_left

    minutes_elapsed * 60 + seconds_elapsed
  end
end
