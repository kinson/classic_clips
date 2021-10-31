defmodule ClassicClips.PickEm.MatchUp do
  use Ecto.Schema
  import Ecto.Changeset

  alias ClassicClips.PickEm.Team

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "matchups" do
    field :month, :string
    field :score, :string
    field :spread, :string
    field :tip_datetime, :utc_datetime

    belongs_to :away_team, Team, type: :binary_id
    belongs_to :home_team, Team, type: :binary_id
    belongs_to :favorite_team, Team, type: :binary_id
    belongs_to :winning_team, Team, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(match_up, attrs) do
    match_up
    |> cast(attrs, [:date, :tip_time, :spread, :score, :month])
    |> validate_required([:date, :tip_time, :spread, :score, :month])
  end
end
