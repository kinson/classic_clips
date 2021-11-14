defmodule ClassicClips.PickEm do
  import Ecto.Query, warn: false

  alias ClassicClips.Repo
  alias ClassicClips.PickEm.{MatchUp, UserPick, NdcPick, UserRecord}
  alias ClassicClips.Timeline.User

  def get_current_matchup() do
    from(m in MatchUp, order_by: [desc: m.tip_datetime], limit: 1)
    |> Repo.one()
    |> Repo.preload([:home_team, :away_team, :favorite_team, :winning_team])
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
    from(ur in UserRecord, where: ur.month == "November", order_by: [desc: ur.wins], limit: 10)
    |> Repo.all()
    |> Repo.preload(:user)
  end
end
