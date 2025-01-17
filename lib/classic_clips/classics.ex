defmodule ClassicClips.Classics do
  @moduledoc """
  The Classics context.
  """

  import Ecto.Query, warn: false
  alias ClassicClips.Repo

  alias ClassicClips.Classics.Video
  alias ClassicClips.Classics.Services.Youtube

  @doc """
  Returns the list of videos.

  ## Examples

      iex> list_videos()
      [%Video{}, ...]

  """
  def list_videos do
    Repo.all(Video)
  end

  def search_classics("", "", %{limit: limit, offset: offset}) do
    clips_query = from c in ClassicClips.Timeline.Clip, select: c.id, where: c.deleted == false

    classics =
      from(v in Video,
        limit: ^limit,
        offset: ^offset,
        order_by: [desc: v.publish_date, desc: v.id]
      )
      |> Repo.all()
      |> Repo.preload(clips: clips_query)

    {:ok, classics}
  end

  def search_classics("", filter, %{limit: limit, offset: offset}) do
    clips_query = from c in ClassicClips.Timeline.Clip, select: c.id, where: c.deleted == false

    classics =
      from(v in Video,
        where: v.type == ^filter,
        limit: ^limit,
        offset: ^offset,
        order_by: [desc: v.publish_date, desc: v.id]
      )
      |> Repo.all()
      |> Repo.preload(clips: clips_query)

    {:ok, classics}
  end

  def search_classics(search_term, "", %{limit: limit, offset: offset}) do
    search = "%#{search_term}%"
    clips_query = from c in ClassicClips.Timeline.Clip, select: c.id, where: c.deleted == false

    classics =
      from(v in Video,
        where: ilike(v.title, ^search),
        limit: ^limit,
        offset: ^offset,
        order_by: [desc: v.publish_date, desc: v.id]
      )
      |> Repo.all()
      |> Repo.preload(clips: clips_query)

    {:ok, classics}
  end

  def search_classics(search_term, filter, %{limit: limit, offset: offset}) do
    search = "%#{search_term}%"
    clips_query = from c in ClassicClips.Timeline.Clip, select: c.id, where: c.deleted == false

    classics =
      from(v in Video,
        where: ilike(v.title, ^search),
        where: v.type == ^filter,
        limit: ^limit,
        offset: ^offset,
        order_by: [desc: v.publish_date, desc: v.id]
      )
      |> Repo.all()
      |> Repo.preload(clips: clips_query)

    {:ok, classics}
  end

  def get_classic_types() do
    from(v in Video,
      select: v.type,
      where: v.type != "classic",
      group_by: v.type
    )
    |> Repo.all()
  end

  @doc """
  Gets a single video.

  Raises `Ecto.NoResultsError` if the Video does not exist.

  ## Examples

      iex> get_video!(123)
      %Video{}

      iex> get_video!(456)
      ** (Ecto.NoResultsError)

  """
  def get_video!(id), do: Repo.get!(Video, id)

  @doc """
  Creates a video.

  ## Examples

      iex> create_video(%{field: value})
      {:ok, %Video{}}

      iex> create_video(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_video(attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a video.

  ## Examples

      iex> update_video(video, %{field: new_value})
      {:ok, %Video{}}

      iex> update_video(video, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a video.

  ## Examples

      iex> delete_video(video)
      {:ok, %Video{}}

      iex> delete_video(video)
      {:error, %Ecto.Changeset{}}

  """
  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking video changes.

  ## Examples

      iex> change_video(video)
      %Ecto.Changeset{data: %Video{}}

  """
  def change_video(%Video{} = video, attrs \\ %{}) do
    Video.changeset(video, attrs)
  end

  def fetch_recent_videos() do
    case Youtube.check_for_new_videos() do
      {:ok, videos} -> insert_videos(videos)
      {:error, _} = error -> error
    end
  end

  def insert_videos(videos) do
    Repo.transaction(fn ->
      Enum.map(videos, &Video.changeset(%Video{}, &1))
      |> Enum.each(
        &Repo.insert!(&1,
          conflict_target: [:yt_video_id],
          on_conflict: {:replace, [:title, :description, :publish_date, :thumbnails]}
        )
      )
    end)
  end
end
