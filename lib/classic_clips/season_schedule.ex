defmodule ClassicClips.SeasonSchedule do
  def get_games_for_day(schedule_data, date) do
    schedule_data
    |> get_month_games(date)
    |> filter_games_for_date(date)
    |> Enum.map(&format_game_data/1)
  end

  defp get_month_games(schedule_data, date) do
    Map.get(schedule_data, "lscd")
    |> Enum.find(fn month_data ->
      # March
      name = String.downcase(month_data["mscd"]["mon"])

      ClassicClips.PickEm.get_month_name(date.month) == name
    end)
    |> Map.get("mscd")
    |> Map.get("g")
  end

  defp filter_games_for_date(games, date) do
    Enum.filter(games, fn game ->
      game_date = Date.from_iso8601!(game["gdte"])
      Date.compare(game_date, date) == :eq
    end)
  end

  defp format_game_data(game) do
    utc_date = Date.from_iso8601!(game["gdtutc"])
    utc_time = Time.from_iso8601!(game["utctm"] <> ":00")
    utc_datetime = DateTime.new!(utc_date, utc_time)

    %{
      game_id: game["gid"],
      game_time_utc: utc_datetime,
      home_team_code: game["h"]["ta"],
      home_team_name: game["h"]["tn"],
      home_team_location: game["h"]["tc"],
      away_team_code: game["v"]["ta"],
      away_team_name: game["v"]["tn"],
      away_team_location: game["v"]["tc"]
    }
  end
end
