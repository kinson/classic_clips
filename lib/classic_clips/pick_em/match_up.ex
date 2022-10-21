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
    field :nba_game_id, :string
    field :status, Ecto.Enum, values: [:unpublished, :published, :completed, :live]
    field :publish_at, :utc_datetime

    belongs_to :away_team, Team, type: :binary_id
    belongs_to :home_team, Team, type: :binary_id
    belongs_to :favorite_team, Team, type: :binary_id
    belongs_to :winning_team, Team, type: :binary_id

    has_many :user_picks, ClassicClips.PickEm.UserPick, foreign_key: :matchup_id
    has_one :ndc_picks, ClassicClips.PickEm.NdcPick, foreign_key: :matchup_id

    timestamps()
  end

  @doc false
  def changeset(match_up, attrs) do
    match_up
    |> cast(attrs, [
      :tip_datetime,
      :spread,
      :score,
      :month,
      :publish_at,
      :away_team_id,
      :home_team_id,
      :nba_game_id,
      :favorite_team_id,
      :status,
      :winning_team_id
    ])
    |> validate_required([
      :tip_datetime,
      :spread,
      :month,
      :nba_game_id,
      :away_team_id,
      :home_team_id,
      :favorite_team_id,
      :status
    ])
  end
end
