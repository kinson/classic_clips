defmodule ClassicClips.PickEm.UserRecord do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "user_records" do
    field :losses, :integer
    field :month, :string
    field :wins, :integer

    belongs_to :user, ClassicClips.Timeline.User, type: :binary_id
    belongs_to :season, ClassicClips.BigBeef.Season, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(user_record, attrs) do
    user_record
    |> cast(attrs, [:wins, :losses, :month, :season_id, :user_id])
    |> validate_required([:wins, :losses, :month, :season_id, :user_id])
  end
end
