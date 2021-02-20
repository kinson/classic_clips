defmodule ClassicClips.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias ClassicClips.Repo

  alias ClassicClips.Timeline.{Clip, Vote, User}

  @doc """
  Returns the list of clips.

  ## Examples

      iex> list_clips()
      [%Clip{}, ...]

  """
  def list_clips do
    Repo.all(Clip) |> Repo.preload(:user)
  end

  def list_newest_clips(%{limit: limit, offset: offset}) do
    clips =
      from(c in Clip,
        select: c,
        order_by: [desc: c.inserted_at, desc: c.id],
        limit: ^limit,
        offset: ^offset
      )
      |> Repo.all()
      |> Repo.preload(:user)

    count =
      from(c in Clip,
        select: count(c.id)
      )
      |> Repo.one()

    {:ok, clips, count}
  end

  @day_in_seconds 60 * 60 * 24

  def list_top_clips_by_date("today", opts) do
    DateTime.utc_now()
    |> DateTime.add(-1 * @day_in_seconds, :second)
    |> list_top_clips(opts)
  end

  def list_top_clips_by_date("week", opts) do
    DateTime.utc_now()
    |> DateTime.add(-1 * 7 * @day_in_seconds, :second)
    |> list_top_clips(opts)
  end

  def list_top_clips_by_date("goat", opts) do
    # This could be a problem 10 years from now...good problem tho
    DateTime.utc_now()
    |> DateTime.add(-1 * 365 * 10 * @day_in_seconds, :second)
    |> list_top_clips(opts)
  end

  @doc """
  Returns the list of clips for a timeframe.

  ## Examples

      iex> list_clips()
      [%Clip{}, ...]

  """
  def list_top_clips(lower_date_bound, %{limit: limit, offset: offset}) do
    clips =
      from(c in Clip,
        select: c,
        where: c.inserted_at > ^lower_date_bound,
        where: c.deleted == false,
        limit: ^limit,
        offset: ^offset,
        order_by: [desc: c.vote_count, desc: c.id]
      )
      |> Repo.all()
      |> Repo.preload(:user)

    count =
      from(c in Clip,
        select: count(c.id),
        where: c.inserted_at > ^lower_date_bound,
        where: c.deleted == false
      )
      |> Repo.one()

    {:ok, clips, count}
  end

  def list_user_clips(user_id, %{limit: limit, offset: offset}) do
    clips =
      from(c in Clip,
        select: c,
        where: c.user_id == ^user_id,
        where: c.deleted == false,
        limit: ^limit,
        offset: ^offset,
        order_by: [desc: c.inserted_at, desc: c.id]
      )
      |> Repo.all()
      |> Repo.preload(:user)

    count =
      from(c in Clip,
        select: count(c.id),
        where: c.user_id == ^user_id,
        where: c.deleted == false
      )
      |> Repo.one()

    {:ok, clips, count}
  end

  def list_saved_clips_for_user(%User{id: id}, %{limit: limit, offset: offset}) do
    clips =
      from(c in Clip,
        join: s in assoc(c, :saves),
        select: c,
        where: s.user_id == ^id,
        where: c.deleted == false,
        limit: ^limit,
        offset: ^offset,
        order_by: [desc: c.inserted_at, desc: c.id]
      )
      |> Repo.all()
      |> Repo.preload(:user)

    count =
      from(c in Clip,
        join: s in assoc(c, :saves),
        select: count(c.id),
        where: s.user_id == ^id,
        where: c.deleted == false
      )
      |> Repo.one()

    {:ok, clips, count}
  end

  def search_new_clips(search_term, %{limit: limit, offset: offset}) do
    search = "%#{search_term}%"

    clips =
      from(c in Clip,
        select: c,
        limit: ^limit,
        offset: ^offset,
        where: ilike(c.title, ^search),
        where: c.deleted == false,
        order_by: [desc: c.inserted_at, desc: c.id]
      )
      |> Repo.all()
      |> Repo.preload(:user)

    count =
      from(c in Clip,
        select: count(c.id),
        where: ilike(c.title, ^search),
        where: c.deleted == false
      )
      |> Repo.one()

    {:ok, clips, count}
  end

  def search_top_clips_by_date(search_term, "today", opts) do
    DateTime.utc_now()
    |> DateTime.add(-1 * @day_in_seconds, :second)
    |> search_top_clips(search_term, opts)
  end

  def search_top_clips_by_date(search_term, "week", opts) do
    DateTime.utc_now()
    |> DateTime.add(-1 * 7 * @day_in_seconds, :second)
    |> search_top_clips(search_term, opts)
  end

  def search_top_clips_by_date(search_term, "goat", opts) do
    # This could be a problem 10 years from now...good problem tho
    DateTime.utc_now()
    |> DateTime.add(-1 * 365 * 10 * @day_in_seconds, :second)
    |> search_top_clips(search_term, opts)
  end

  defp search_top_clips(lower_date_bound, search_term, %{limit: limit, offset: offset}) do
    search = "%#{search_term}%"

    clips =
      from(c in Clip,
        select: c,
        where: c.inserted_at > ^lower_date_bound,
        where: ilike(c.title, ^search),
        where: c.deleted == false,
        limit: ^limit,
        offset: ^offset,
        order_by: [desc: c.vote_count, desc: c.id]
      )
      |> Repo.all()
      |> Repo.preload(:user)

    count =
      from(c in Clip,
        select: count(c.id),
        where: c.inserted_at > ^lower_date_bound,
        where: ilike(c.title, ^search),
        where: c.deleted == false
      )
      |> Repo.one()

    {:ok, clips, count}
  end

  def get_users_clips_vote_total(%User{} = user) do
    from(c in Clip,
      select: sum(c.vote_count),
      where: c.user_id == ^user.id
    )
    |> Repo.one()
  end

  @doc """
  Gets a single clip.

  Raises `Ecto.NoResultsError` if the Clip does not exist.

  ## Examples

      iex> get_clip!(123)
      %Clip{}

      iex> get_clip!(456)
      ** (Ecto.NoResultsError)

  """
  def get_clip!(id), do: Repo.get!(Clip, id)

  @doc """
  Creates a clip.

  ## Examples

      iex> create_clip(%{field: value})
      {:ok, %Clip{}}

      iex> create_clip(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_clip(attrs \\ %{}) do
    %Clip{}
    |> Clip.changeset(attrs)
    |> Repo.insert()
  end

  def insert_clip(%Ecto.Changeset{} = clip) do
    Repo.insert(clip) |> broadcast(:clip_created)
  end

  @doc """
  Updates a clip.

  ## Examples

      iex> update_clip(clip, %{field: new_value})
      {:ok, %Clip{}}

      iex> update_clip(clip, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_clip(%Clip{} = clip, attrs) do
    clip
    |> Clip.changeset(attrs)
    |> Repo.update()
  end

  def inc_votes(clip_id, %User{id: user_id}) do
    {:ok, clip} =
      from(c in Clip, where: c.id == ^clip_id, select: c)
      |> Repo.update_all(inc: [vote_count: 1])
      |> case do
        {1, [clip]} -> {:ok, Repo.preload(clip, :user)}
        error -> error
      end

    {:ok, vote} =
      Vote.changeset(%Vote{}, %{clip_id: clip_id, user_id: user_id, up: true})
      |> Repo.insert(returning: true)

    broadcast({:ok, clip}, :clip_updated)

    {:ok, vote}
  end

  @doc """
  Deletes a clip.

  ## Examples

      iex> delete_clip(clip)
      {:ok, %Clip{}}

      iex> delete_clip(clip)
      {:error, %Ecto.Changeset{}}

  """
  def delete_clip(%Clip{} = clip) do
    Clip.changeset(clip, %{deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking clip changes.

  ## Examples

      iex> change_clip(clip)
      %Ecto.Changeset{data: %Clip{}}

  """
  def change_clip(%Clip{} = clip, attrs \\ %{}) do
    Clip.changeset(clip, attrs)
  end

  alias ClassicClips.Timeline.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update(returning: true)
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias ClassicClips.Timeline.Vote

  @doc """
  Returns the list of votes.

  ## Examples

      iex> list_votes()
      [%Vote{}, ...]

  """
  def list_votes do
    Repo.all(Vote)
  end

  def list_votes_for_user(%User{id: id}) do
    from(v in Vote, where: v.user_id == ^id, select: v) |> Repo.all()
  end

  @doc """
  Gets a single vote.

  Raises `Ecto.NoResultsError` if the Vote does not exist.

  ## Examples

      iex> get_vote!(123)
      %Vote{}

      iex> get_vote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_vote!(id), do: Repo.get!(Vote, id)

  @doc """
  Creates a vote.

  ## Examples

      iex> create_vote(%{field: value})
      {:ok, %Vote{}}

      iex> create_vote(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vote(attrs \\ %{}) do
    %Vote{}
    |> Vote.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vote.

  ## Examples

      iex> update_vote(vote, %{field: new_value})
      {:ok, %Vote{}}

      iex> update_vote(vote, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vote(%Vote{} = vote, attrs) do
    vote
    |> Vote.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vote.

  ## Examples

      iex> delete_vote(vote)
      {:ok, %Vote{}}

      iex> delete_vote(vote)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vote(%Vote{} = vote) do
    Repo.delete(vote)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vote changes.

  ## Examples

      iex> change_vote(vote)
      %Ecto.Changeset{data: %Vote{}}

  """
  def change_vote(%Vote{} = vote, attrs \\ %{}) do
    Vote.changeset(vote, attrs)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(ClassicClips.PubSub, "clips")
  end

  def subscribe(clips) do
    Enum.map(clips, & &1.id)
    |> Enum.each(fn clip_id ->
      Phoenix.PubSub.subscribe(ClassicClips.PubSub, "clip:#{clip_id}")
    end)
  end

  def subscribe_new() do
    Phoenix.PubSub.subscribe(ClassicClips.PubSub, "new")
  end

  def unsubscribe_new() do
    Phoenix.PubSub.unsubscribe(ClassicClips.PubSub, "new")
  end

  def resubscribe(unsub_list, sub_list) do
    Enum.map(sub_list, & &1.id)
    |> Enum.each(fn clip_id ->
      Phoenix.PubSub.subscribe(ClassicClips.PubSub, "clip:#{clip_id}")
    end)

    Enum.map(unsub_list, & &1.id)
    |> Enum.each(fn clip_id ->
      Phoenix.PubSub.unsubscribe(ClassicClips.PubSub, "clip:#{clip_id}")
    end)
  end

  defp broadcast({:error, _reason} = error, _), do: error

  defp broadcast({:ok, clip}, :clip_created) do
    Phoenix.PubSub.broadcast(ClassicClips.PubSub, "new", {:clip_created, clip})
    {:ok, clip}
  end

  defp broadcast({:ok, clip}, event) do
    Phoenix.PubSub.broadcast(ClassicClips.PubSub, "clip:#{clip.id}", {event, clip})
    {:ok, clip}
  end

  def get_vote_class(_, _, user) when is_nil(user), do: "leigh-score-not-logged-in"

  def get_vote_class(clip_id, votes, user) do
    case can_vote?(clip_id, votes, user) do
      true -> "leigh-score-not-voted"
      false -> "leigh-score-voted"
    end
  end

  def can_vote?(clip_id, votes, user) do
    not is_nil(user) and not has_voted_already?(clip_id, votes)
  end

  defp has_voted_already?(clip_id, votes) do
    Enum.any?(votes, fn vote -> vote.clip_id == clip_id end)
  end

  alias ClassicClips.Timeline.Save

  @doc """
  Returns the list of saves.

  ## Examples

      iex> list_saves()
      [%Save{}, ...]

  """
  def list_saves do
    Repo.all(Save)
  end

  def list_saves_for_user(%User{id: id}) do
    from(
      s in Save,
      select: s,
      where: s.user_id == ^id
    )
    |> Repo.all()
  end

  @doc """
  Gets a single save.

  Raises `Ecto.NoResultsError` if the Save does not exist.

  ## Examples

      iex> get_save!(123)
      %Save{}

      iex> get_save!(456)
      ** (Ecto.NoResultsError)

  """
  def get_save!(id), do: Repo.get!(Save, id)

  @doc """
  Creates a save.

  ## Examples

      iex> create_save(%{field: value})
      {:ok, %Save{}}

      iex> create_save(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_save(attrs \\ %{}) do
    %Save{}
    |> Save.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a save.

  ## Examples

      iex> update_save(save, %{field: new_value})
      {:ok, %Save{}}

      iex> update_save(save, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_save(%Save{} = save, attrs) do
    save
    |> Save.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a save.

  ## Examples

      iex> delete_save(save)
      {:ok, %Save{}}

      iex> delete_save(save)
      {:error, %Ecto.Changeset{}}

  """
  def delete_save(%Save{} = save) do
    Repo.delete(save)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking save changes.

  ## Examples

      iex> change_save(save)
      %Ecto.Changeset{data: %Save{}}

  """
  def change_save(%Save{} = save, attrs \\ %{}) do
    Save.changeset(save, attrs)
  end
end
