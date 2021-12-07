defmodule ClassicClips.PickEm do
  import Ecto.Query, warn: false

  require Logger

  alias ClassicClips.Repo
  alias ClassicClips.PickEm.{MatchUp, UserPick, NdcPick, UserRecord, Team}
  alias ClassicClips.Timeline.User

  @new_york_offset 5 * 60 * 60

  def get_cached_current_matchup() do
    Fiat.CacheServer.fetch_object(:current_matchup, &get_current_matchup/0, 300)
  end

  def get_current_matchup() do
    from(m in MatchUp,
      order_by: [desc: m.tip_datetime],
      limit: 1
    )
    |> Repo.one()
    |> Repo.preload([:home_team, :away_team, :favorite_team, :winning_team])
  end

  def get_cached_ndc_pick_for_matchup(%MatchUp{id: id} = matchup) do
    Fiat.CacheServer.fetch_object(
      {:ndc_pick, id},
      fn -> get_ndc_pick_for_matchup(matchup) end,
      300
    )
  end

  def get_ndc_pick_for_matchup(%MatchUp{id: id}) do
    Repo.get_by(NdcPick, matchup_id: id)
    |> Repo.preload([:skeets_pick_team, :leigh_pick_team, :tas_pick_team, :trey_pick_team])
  end

  def get_user_pick_for_matchup(nil, _), do: nil

  def get_user_pick_for_matchup(%User{id: user_id}, %MatchUp{id: matchup_id}) do
    Repo.get_by(UserPick, matchup_id: matchup_id, user_id: user_id)
    |> Repo.preload([:picked_team])
  end

  def save_user_pick(nil, selected_team, %User{id: user_id}, %MatchUp{id: matchup_id}) do
    UserPick.changeset(%UserPick{}, %{
      user_id: user_id,
      matchup_id: matchup_id,
      picked_team_id: selected_team.id
    })
    |> Repo.insert()
  end

  def save_user_pick(%UserPick{} = user_pick, selected_team, %User{id: user_id}, _)
      when user_pick.user_id == user_id do
    UserPick.changeset(user_pick, %{picked_team_id: selected_team.id})
    |> Repo.update()
  end

  def get_pick_count_for_matchup(%MatchUp{id: id}) do
    from(up in UserPick, select: count(up.id), where: up.matchup_id == ^id) |> Repo.one()
  end

  def get_leaders() do
    current_month = get_current_month_name()

    from(ur in UserRecord, where: ur.month == ^current_month, order_by: [desc: ur.wins], limit: 10)
    |> Repo.all()
    |> Repo.preload(:user)
  end

  def update_user_picks_with_matchup_result(game_data, matchup) do
    user_picks =
      from(up in UserPick, where: up.matchup_id == ^matchup.id)
      |> Repo.all()
      |> Repo.preload([:picked_team])

    game_winning_team_id = get_game_winning_team_id(game_data, matchup)
    spread_winning_team_id = get_spread_winning_team_id(game_data, matchup)

    update_matchup_with_winner(matchup, game_winning_team_id, game_data)

    user_picks
    |> Enum.map(fn pick ->
      case pick.picked_team.id do
        ^spread_winning_team_id -> UserPick.changeset(pick, %{result: :win})
        _ -> UserPick.changeset(pick, %{result: :loss})
      end
    end)
    |> Enum.map(&Repo.update/1)

    season = Repo.get_by!(ClassicClips.BigBeef.Season, current: true)

    user_picks
    |> Enum.map(fn pick ->
      if pick.picked_team_id == spread_winning_team_id do
        create_or_update_user_record(pick.user_id, season.id, 1, 0)
      else
        create_or_update_user_record(pick.user_id, season.id, 0, 1)
      end
    end)

    Logger.notice("Updated #{Enum.count(user_picks)} user picks")
  end

  def get_game_winning_team_id(
        %{away: %{score: away_team_score}, home: %{score: home_team_score}},
        %{
          home_team_id: home_team_id,
          away_team_id: away_team_id
        }
      ) do
    if away_team_score > home_team_score do
      away_team_id
    else
      home_team_id
    end
  end

  defp get_spread_winning_team_id(
         %{away: %{score: away_team_score}, home: %{score: home_team_score}},
         %{
           home_team_id: home_team_id,
           away_team_id: away_team_id,
           spread: spread,
           favorite_team_id: favorite_team_id
         }
       )
       when home_team_id == favorite_team_id do
    case spread_winner(home_team_score, away_team_score, spread) do
      :favorite_team -> home_team_id
      :other_team -> away_team_id
    end
  end

  defp get_spread_winning_team_id(
         %{away: %{score: away_team_score}, home: %{score: home_team_score}},
         %{
           home_team_id: home_team_id,
           away_team_id: away_team_id,
           spread: spread,
           favorite_team_id: favorite_team_id
         }
       )
       when away_team_id == favorite_team_id do
    case spread_winner(away_team_score, home_team_score, spread) do
      :favorite_team -> away_team_id
      :other_team -> home_team_id
    end
  end

  def spread_winner(favorite_team_score, other_team_score, spread_string) do
    spread =
      spread_string
      |> String.replace("-", "")
      |> String.to_float()

    if favorite_team_score - other_team_score > spread do
      :favorite_team
    else
      :other_team
    end
  end

  defp update_matchup_with_winner(matchup, winning_team_id, %{
         away: %{score: away_team_score},
         home: %{score: home_team_score}
       }) do
    game_score = "#{away_team_score} - #{home_team_score}"

    MatchUp.changeset(matchup, %{winning_team_id: winning_team_id, score: game_score})
    |> Repo.update()
  end

  defp create_or_update_user_record(user_id, season_id, win_increment, loss_increment) do
    current_month = get_current_month_name()

    case Repo.get_by(UserRecord, user_id: user_id, month: current_month) do
      nil ->
        UserRecord.changeset(%UserRecord{}, %{
          wins: 0 + win_increment,
          losses: 0 + loss_increment,
          user_id: user_id,
          month: current_month,
          season_id: season_id
        })
        |> Repo.insert()

      user_record ->
        UserRecord.changeset(user_record, %{
          wins: user_record.wins + win_increment,
          losses: user_record.losses + loss_increment
        })
        |> Repo.update()
    end
  end

  def get_cached_teams_for_conference(conference) do
    Fiat.CacheServer.fetch_object(conference, fn -> get_teams_for_conference(conference) end, 600)
  end

  def get_teams_for_conference(conference) do
    from(t in Team, where: t.conference == ^conference, order_by: [asc: t.location]) |> Repo.all()
  end

  def get_custom_team_emojis(emojis, teams) do
    # emojis %{"CHA" => %{"sadkasd9" => "emoji"}}
    # [%{"saddasd" => "emoji"}]
    # %{"dkdkdksd" => "emoji"} 

    emoji_teams_by_id =
      Enum.reduce(teams, %{}, fn %Team{id: id} = team, acc ->
        Map.put(acc, id, team.default_emoji)
      end)

    Enum.filter(emojis, fn {id, emoji} ->
      Map.fetch!(emoji_teams_by_id, id) != emoji
    end)
    |> Enum.into(%{})
  end

  def get_picks_for_user(%User{id: user_id}) do
    from(up in UserPick,
      where: up.user_id == ^user_id,
      order_by: [desc: up.inserted_at],
      limit: 10
    )
    |> Repo.all()
    |> Repo.preload([
      :picked_team,
      matchup: [:away_team, :home_team, :favorite_team, :winning_team]
    ])
  end

  def get_current_month_name do
    DateTime.utc_now()
    |> DateTime.add(-1 * get_est_offset_seconds())
    |> Map.get(:month)
    |> get_month_name()
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

  def get_est_offset_seconds do
    @new_york_offset
  end
end
