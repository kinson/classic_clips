defmodule ClassicClips.PickEm.NdcRecord do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "ndc_records" do
    field :month, :string
    field :skeets_wins, :integer, default: 0
    field :skeets_losses, :integer, default: 0
    field :tas_wins, :integer, default: 0
    field :tas_losses, :integer, default: 0
    field :trey_wins, :integer, default: 0
    field :trey_losses, :integer, default: 0

    belongs_to :season, ClassicClips.BigBeef.Season, type: :binary_id
    belongs_to :latest_matchup, ClassicClips.PickEm.MatchUp, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(ndc_record, attrs) do
    ndc_record
    |> cast(attrs, [
      :month,
      :skeets_wins,
      :skeets_losses,
      :tas_wins,
      :tas_losses,
      :trey_wins,
      :trey_losses,
      :latest_matchup_id
    ])
    |> validate_required([:month])
  end
end
