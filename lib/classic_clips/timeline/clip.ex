defmodule ClassicClips.Timeline.Clip do
  use Ecto.Schema
  import Ecto.Changeset

  alias ClassicClips.Timeline.{Clip}
  alias ClassicClips.Classics.{Video}

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
    belongs_to :video, ClassicClips.Classics.Video, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(clip, attrs) do
    clip
    |> cast(attrs, [
      :yt_video_url,
      :yt_thumbnail_url,
      :clip_length,
      :title,
      :user_id,
      :deleted,
      :video_id
    ])
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

  def description(%Clip{video: %Video{} = video}) do
    {:ok, dt, 0} = DateTime.from_iso8601(video.publish_date)
    date = format_video_date(dt)
    "From a Classic on #{date}: #{video.title}"
  end

  defp format_video_date(time) do
    six_hour_back_offset = -1 * 60 * 60 * 6

    d =
      time
      |> DateTime.add(six_hour_back_offset, :second)
      |> DateTime.to_date()

    month = d.month
    day = d.day
    year = d.year

    month =
      case month do
        1 -> "January"
        2 -> "February"
        3 -> "March"
        4 -> "April"
        5 -> "May"
        6 -> "June"
        7 -> "July"
        8 -> "August"
        9 -> "September"
        10 -> "October"
        11 -> "November"
        12 -> "December"
      end

    day_th =
      case day do
        n when n in [1, 21, 31] -> "st"
        n when n in [2, 22] -> "nd"
        n when n in [3, 23] -> "rd"
        _ -> "th"
      end

    "#{month} #{day}#{day_th}, #{year}"
  end
end
