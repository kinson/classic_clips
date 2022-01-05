defmodule ClassicClips.GameSchedule do
  @todays_games_url "https://stats.nba.com/stats/scoreboardv3?LeagueID=00&GameDate="

  def get_game_schedule(%Date{} = date) do
    date_string = "#{date.year}-#{date.month}-#{date.day}"

    with {:ok, %HTTPoison.Response{body: body}} <-
           (@todays_games_url <> date_string)
           |> HTTPoison.get(
             referer: "https://www.nba.com",
             origin: "https://www.nba.com",
             Accept: "*/*",
             "Content-Type": "application/json",
             "User-Agent":
               "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:96.0) Gecko/20100101 Firefox/96.0",
             "Accept-Encoding": "gzip, deflate, br"
           ),
         {:ok, data} <- Jason.decode(body |> :zlib.gunzip()),
         schedule <- parse_game_schedule(data) do
      {:ok, schedule}
    else
      {:error, _} = error -> error
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
