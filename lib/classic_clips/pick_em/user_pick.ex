defmodule ClassicClips.PickEm.UserPick do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "user_picks" do
    field :result, :string

    belongs_to :user, ClassicClips.Timeline.User, type: :binary_id
    belongs_to :matchup, ClassicClips.PickEm.MatchUp, type: :binary_id
    belongs_to :picked_team, ClassicClips.PickEm.Team, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(user_pick, attrs) do
    user_pick
    |> cast(attrs, [:result, :user_id, :matchup_id, :picked_team_id])
    |> validate_required([:user_id, :matchup_id, :picked_team_id])
  end
end
