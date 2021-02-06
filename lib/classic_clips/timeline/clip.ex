defmodule ClassicClips.Timeline.Clip do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "clips" do
    field :clip_length, :integer
    field :title, :string
    field :video_ext_id, :string

    belongs_to :user, ClassicClips.Timeline.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(clip, attrs) do
    clip
    |> cast(attrs, [:video_ext_id, :clip_length, :title])
    |> validate_required([:video_ext_id, :clip_length, :title])
  end
end
