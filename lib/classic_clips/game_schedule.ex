defmodule ClassicClips.GameSchedule do
  @todays_games_url "https://cdn.nba.com/static/json/liveData/scoreboard/todaysScoreboard_00.json"

  require Logger

  def get_game_schedule() do
    with {:ok, %HTTPoison.Response{body: body}} <-
           HTTPoison.get(@todays_games_url),
         {:ok, data} <- Jason.decode(body),
         schedule <- parse_game_schedule(data) do
      {:ok, schedule}
    else
      {:error, message} = error ->
        Logger.error("Failed to fetch schedule data",
          error: message,
          request_url: @todays_games_url
        )

        error
    end
  end

  defp parse_game_schedule(schedule) when is_map(schedule) do
    schedule
    |> Map.get("scoreboard")
    |> Map.get("games")
    |> Enum.map(fn %{
                     "gameId" => game_id,
                     "gameTimeUTC" => game_time_utc,
                     "homeTeam" => %{
                       "teamName" => home_team_name,
                       "teamTricode" => home_team_code,
                       "teamCity" => home_team_location
                     },
                     "awayTeam" => %{
                       "teamName" => away_team_name,
                       "teamTricode" => away_team_code,
                       "teamCity" => away_team_location
                     }
                   } ->
      {:ok, game_time_utc, _} = DateTime.from_iso8601(game_time_utc)

      %{
        game_id: game_id,
        game_time_utc: game_time_utc,
        home_team_code: home_team_code,
        home_team_name: home_team_name,
        home_team_location: home_team_location,
        away_team_code: away_team_code,
        away_team_name: away_team_name,
        away_team_location: away_team_location
      }
    end)
  end
end
