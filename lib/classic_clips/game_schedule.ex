defmodule ClassicClips.GameSchedule do
  @todays_games_url "https://stats.nba.com/stats/scoreboardv3?LeagueID=00&GameDate="

  require Logger

  def get_game_schedule(%Date{} = date) do
    date_string = "#{date.year}-#{date.month}-#{date.day}"
    request_url = @todays_games_url <> date_string

    headers = [
      Referer: "https://www.nba.com",
      Origin: "https://www.nba.com",
      Connection: "keep-alive",
      "Accept-Lanuage": "en-US,en;q=0.5",
      Accept: "*/*",
      "Content-Type": "application/json",
      "User-Agent":
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:96.0) Gecko/20100101 Firefox/96.0",
      "Accept-Encoding": "gzip, deflate, br",
      "Sec-Fetch-Mode": "no-cors",
      "Cache-Control": "no-cache"
    ]

    options = [recv_timeout: 10000]

    :hackney_trace.enable(:max, :io)

    with {:ok, %HTTPoison.Response{body: body}} <-
           HTTPoison.get(request_url, headers, options),
         {:ok, data} <- Jason.decode(body |> :zlib.gunzip()),
         schedule <- parse_game_schedule(data) do
      {:ok, schedule}
    else
      {:error, message} = error ->
        Logger.error("Failed to fetch schedule data", error: message, request_url: request_url)
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
