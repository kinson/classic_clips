defmodule ClassicClips.Classics.Video do
  use Ecto.Schema
  import Ecto.Changeset

  schema "videos" do
    field :description, :string
    field :publish_date, :string
    field :title, :string
    field :type, :string
    field :yt_thumbnail_url, :string
    field :yt_video_id, :string
    field :yt_video_url, :string

    timestamps()
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:publish_date, :yt_video_id, :yt_video_url, :type, :title, :description, :yt_thumbnail_url])
    |> validate_required([:publish_date, :yt_video_id, :yt_video_url, :type, :title, :description, :yt_thumbnail_url])
  end
end
