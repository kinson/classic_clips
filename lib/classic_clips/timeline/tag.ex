defmodule ClassicClips.Timeline.Tag do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "tags" do
    field :name, :string
    field :code, :string
    field :type, :string
    field :enabled, :boolean, default: true

    many_to_many :clips, ClassicClips.Timeline.Clip, join_through: "clips_tags"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:enabled, :name, :code, :type])
    |> validate_required([:name, :code, :type])
  end
end
