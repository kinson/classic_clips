defmodule ClassicClips.Timeline.ClipsTags do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "clips_tags" do
    belongs_to :clip, ClassicClips.Timeline.Clip, type: :binary_id
    belongs_to :tag, ClassicClips.Timeline.Tag, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(clips_tags, attrs) do
    clips_tags
    |> cast(attrs, [:clip_id, :tag_id])
    |> validate_required([:clip_id, :tag_id])
  end
end
