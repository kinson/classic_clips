defmodule ClassicClips.BigBeef.Beef do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "beefs" do
    field :beef_count, :integer
    field :date_time, :utc_datetime
    field :ext_game_id, :string
    field :game_time, :integer

    belongs_to :player, ClassicClips.BigBeef.Player, type: :binary_id
    belongs_to :season, ClassicClips.BigBeef.Season, type: :binary_id

    has_one :big_beef_event, ClassicClips.BigBeef.BigBeefEvent

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(beef, attrs) do
    beef
    |> cast(attrs, [:date_time, :beef_count, :game_time, :ext_game_id, :player_id, :season_id])
    |> validate_required([:beef_count, :ext_game_id, :game_time, :player_id, :season_id])
  end
end
