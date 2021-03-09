defmodule ClassicClips.Classics.Video do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "videos" do
    field :description, :string
    field :publish_date, :string
    field :title, :string
    field :type, :string
    field :thumbnails, :map
    field :yt_video_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(video, attrs) do
    video
    |> cast(attrs, [:publish_date, :yt_video_id, :type, :title, :description, :thumbnails])
    |> validate_required([:publish_date, :yt_video_id, :type, :title, :description, :thumbnails])
  end
end
