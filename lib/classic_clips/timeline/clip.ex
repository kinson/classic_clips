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

    belongs_to :user, ClassicClips.Timeline.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(clip, attrs) do
    clip
    |> cast(attrs, [:yt_video_url, :yt_thumbnail_url, :clip_length, :title, :user_id])
    |> validate_required([:yt_video_url, :yt_thumbnail_url, :title, :user_id])
  end
end
