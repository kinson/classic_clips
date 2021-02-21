defmodule ClassicClips.Timeline.Clip do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "clips" do
    field :clip_length, :integer
    field :title, :string
    field :yt_video_url, :string
    field :yt_thumbnail_url, :string
    field :vote_count, :integer
    field :deleted, :boolean, default: false

    belongs_to :user, ClassicClips.Timeline.User, type: :binary_id
    has_many :saves, ClassicClips.Timeline.Save
    many_to_many :tags, ClassicClips.Timeline.Tag, join_through: "clips_tags"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(clip, attrs) do
    clip
    |> cast(attrs, [:yt_video_url, :yt_thumbnail_url, :clip_length, :title, :user_id, :deleted])
    |> validate_required([:yt_video_url, :title, :user_id])
    |> unique_constraint([:title, :user_id],
      message: "Cannot create two clips with the same title"
    )
    |> validate_length(:title, min: 2, max: 72)
    |> validate_format(:yt_video_url, ~r/(youtube.com|youtu.be).*t=[0-9]+/,
      message: "Must be a Youtube link with a timestamp"
    )
    |> validate_number(:clip_length, greater_than: 0, less_than: 2000)
  end
end
