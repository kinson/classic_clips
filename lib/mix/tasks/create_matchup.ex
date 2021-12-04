defmodule Mix.Tasks.CreateMatchup do
  use Mix.Task

  alias ClassicClips.{PickEm, Repo}
  alias ClassicClips.PickEm.{MatchUp, Team, NdcPick}

  @new_york_offset 5 * 60 * 60

  @impl Mix.Task
  def run(args) do
    Application.ensure_all_started(:classic_clips)

    create_matchup(args)
  end

  defp create_matchup([
         away_abbreviation,
         home_abbreviation,
         favorite_abbreviation,
         spread,
         game_id,
         game_tip_time_est,
         leigh_pick_team,
         skeets_pick_team,
         tas_pick_team,
         trey_pick_team
       ]) do
    # get away team
    away_team = Repo.get_by!(Team, abbreviation: away_abbreviation)
    # get home team
    home_team = Repo.get_by!(Team, abbreviation: home_abbreviation)
    # get favorite team
    favorite_team = Repo.get_by!(Team, abbreviation: favorite_abbreviation)

    # convert game tip time
    # 17:30 ->  2021-11-29 00:00:00Z
    [hour, minute] = String.split(game_tip_time_est, ":")
    tip_time = Time.new!(String.to_integer(hour), String.to_integer(minute), 0)
    tip_date = Date.utc_today()

    tip_datetime_est = DateTime.new!(tip_date, tip_time)
    tip_datetime_utc = DateTime.add(tip_datetime_est, @new_york_offset)

    month = get_month_name(tip_datetime_est.month)

    matchup =
      MatchUp.changeset(%MatchUp{}, %{
        month: month,
        spread: spread,
        tip_datetime: tip_datetime_utc,
        nba_game_id: game_id,
        away_team_id: away_team.id,
        home_team_id: home_team.id,
        favorite_team_id: favorite_team.id
      })
      |> Repo.insert!()

    NdcPick.changeset(%NdcPick{}, %{
      matchup_id: matchup.id,
      skeets_pick_team_id: get_ndc_team_id(away_team, home_team, skeets_pick_team),
      tas_pick_team_id: get_ndc_team_id(away_team, home_team, tas_pick_team),
      trey_pick_team_id: get_ndc_team_id(away_team, home_team, trey_pick_team),
      leigh_pick_team_id: get_ndc_team_id(away_team, home_team, leigh_pick_team)
    })
    |> Repo.insert!()
  end

  defp create_matchup(_) do
    raise """
    Invalid args. Could not create matchup.
    Use format:\n
                        a   h   f    l   gameid    t    L   S   T   Trey
    mix create_matchup UTA PHX UTA -1.5 00394938 17:30 UTA PHX PHX UTA\n
    """
  end

  def get_month_name(1), do: "january"
  def get_month_name(2), do: "february"
  def get_month_name(3), do: "march"
  def get_month_name(4), do: "april"
  def get_month_name(5), do: "may"
  def get_month_name(6), do: "june"
  def get_month_name(7), do: "july"
  def get_month_name(8), do: "august"
  def get_month_name(9), do: "september"
  def get_month_name(10), do: "october"
  def get_month_name(11), do: "november"
  def get_month_name(12), do: "december"

  defp get_ndc_team_id(%Team{abbreviation: away_team_abbrev} = away_team, _, away_team_abbrev),
    do: away_team.id

  defp get_ndc_team_id(_, %Team{abbreviation: home_team_abbrev} = home_team, home_team_abbrev),
    do: home_team.id
end
