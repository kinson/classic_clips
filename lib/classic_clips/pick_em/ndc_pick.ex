defmodule ClassicClips.PickEm.NdcPick do
  use Ecto.Schema
  import Ecto.Changeset

  alias ClassicClips.PickEm.{Team, MatchUp}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "ndc_picks" do
    belongs_to :matchup, MatchUp, type: :binary_id
    belongs_to :skeets_pick_team, Team, type: :binary_id
    belongs_to :tas_pick_team, Team, type: :binary_id
    belongs_to :trey_pick_team, Team, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(ndc_pick, attrs) do
    ndc_pick
    |> cast(attrs, [
      :skeets_pick_team_id,
      :tas_pick_team_id,
      :trey_pick_team_id,
      :matchup_id
    ])
    |> validate_required([:matchup_id])
  end
end
