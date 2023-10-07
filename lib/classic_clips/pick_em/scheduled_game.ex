defmodule ClassicClips.PickEm.ScheduledGame do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "scheduled_games" do
    field :external_id, :string
    field :date, :date
    field :start_time_et, :string
    field :dt_utc, :utc_datetime

    belongs_to :away_team, ClassicClips.PickEm.Team, type: :binary_id
    belongs_to :home_team, ClassicClips.PickEm.Team, type: :binary_id

    belongs_to :season, ClassicClips.BigBeef.Season, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(scheduled_game, attrs) do
    scheduled_game
    |> cast(attrs, [
      :external_id,
      :date,
      :start_time_et,
      :dt_utc,
      :away_team_id,
      :home_team_id,
      :season_id
    ])
    |> unique_constraint(:external_id)
  end
end
