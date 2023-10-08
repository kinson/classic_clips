defmodule Mix.Tasks.ConvertScheduleJson do
  @moduledoc """
  Load teams into the database if they are not already present.
  """

  use Mix.Task

  alias ClassicClips.Repo

  alias ClassicClips.PickEm.{ScheduledGame, Team}
  alias ClassicClips.BigBeef.Season

  import Ecto.Query

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    [file_name | _] = args

    input_file = Path.join("./", file_name)

    current_season = Repo.one(from s in Season, where: s.current)

    teams_by_abbreviation = Repo.all(Team) |> Enum.group_by(& &1.abbreviation)

    slim_schedule =
      File.read!(input_file)
      |> Jason.decode!()
      |> Map.get("lscd")
      |> Enum.flat_map(fn %{"mscd" => month} ->
        Map.get(month, "g")
      end)
      |> Enum.filter(fn %{"v" => away_team, "h" => home_team} ->
        has_away_team_id? = Map.has_key?(teams_by_abbreviation, away_team["ta"])
        has_home_team_id? = Map.has_key?(teams_by_abbreviation, home_team["ta"])

        has_away_team_id? and has_home_team_id?
      end)
      |> Enum.map(fn game ->
        %{
          "gid" => external_id,
          "gdte" => game_date,
          "stt" => game_start_et,
          "gdtutc" => gdutc,
          "utctm" => utctm,
          "v" => away_team,
          "h" => home_team
        } = game

        game_dt_utc =
          DateTime.new!(Date.from_iso8601!(gdutc), Time.from_iso8601!("#{utctm}:00"))

        away_team_id = Map.get(teams_by_abbreviation, away_team["ta"]) |> hd() |> Map.get(:id)
        home_team_id = Map.get(teams_by_abbreviation, home_team["ta"]) |> hd() |> Map.get(:id)

        ScheduledGame.changeset(%ScheduledGame{}, %{
          external_id: external_id,
          date: game_date,
          dt_utc: game_dt_utc,
          start_time_et: game_start_et,
          away_team_id: away_team_id,
          home_team_id: home_team_id,
          season_id: current_season.id
        })
      end)
      |> Enum.map(fn cs ->
        model = Ecto.Changeset.apply_action!(cs, :create)

        model
        |> Map.from_struct()
        |> Map.merge(%{
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          id: Ecto.UUID.generate()
        })
        |> Map.drop([:__meta__, :away_team, :home_team, :season])
      end)

    Repo.insert_all(ScheduledGame, slim_schedule,
      on_conflict: {:replace_all_except, [:id, :inserted_at]},
      conflict_target: [:external_id]
    )
  end
end
