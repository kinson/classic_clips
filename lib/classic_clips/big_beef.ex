defmodule ClassicClips.BigBeef do
  @moduledoc """
  The BigBeef context.
  """

  import Ecto.Query, warn: false
  alias ClassicClips.Repo

  alias ClassicClips.BigBeef.Beef
  alias ClassicClips.GameData

  @doc """
  Returns the list of beefs.

  ## Examples

      iex> list_beefs()
      [%Beef{}, ...]

  """
  def list_beefs do
    Repo.all(Beef)
  end

  def get_latest_big_beef() do
    from(b in ClassicClips.BigBeef.BigBeefEvent,
      select: b,
      order_by: [desc: b.inserted_at],
      limit: 1
    )
    |> Repo.one()
    |> Repo.preload(beef: [:player])
  end

  def get_single_game_leaders() do
    from(b in ClassicClips.BigBeef.Beef, select: b, order_by: [desc: b.beef_count], limit: 10)
    |> Repo.all()
    |> Repo.preload(:player)
  end

  def get_big_beef_count_leaders() do
    from(bb in ClassicClips.BigBeef.BigBeefEvent,
      join: b in assoc(bb, :beef),
      join: p in assoc(b, :player),
      select: {b.player_id, p.first_name, p.last_name, count(b.id)},
      group_by: [b.player_id, p.first_name, p.last_name],
      order_by: [desc: count(b.id)],
      limit: 10
    )
    |> Repo.all()
  end

  @doc """
  Gets a single beef.

  Raises `Ecto.NoResultsError` if the Beef does not exist.

  ## Examples

      iex> get_beef!(123)
      %Beef{}

      iex> get_beef!(456)
      ** (Ecto.NoResultsError)

  """
  def get_beef!(id), do: Repo.get!(Beef, id)

  def get_recent_beefs_cached(offset \\ 12) do
    alias ClassicClips.BigBeef.RecentBeefCache

    case RecentBeefCache.get_recent_beefs(offset) do
      nil -> get_recent_beefs(offset) |> RecentBeefCache.apply_cache(offset)
      beef -> beef
    end
  end

  # if there are no active games, reach further back for beefs
  def get_recent_beefs(0) do
    get_beefs(24)
  end

  def get_recent_beefs(_) do
    get_beefs(12)
  end

  def get_recent_beefs() do
    get_beefs(12)
  end

  def get_beefs(hours_offset) do
    offset = -1 * 60 * 60 * hours_offset
    lower_date_bound = DateTime.utc_now() |> DateTime.add(offset, :second)

    from(b in Beef,
      join: p in assoc(b, :player),
      select: %{
        beef_count: max(b.beef_count),
        game_time: max(b.game_time),
        date_time: max(b.date_time),
        inserted_at: max(b.inserted_at),
        player_first_name: max(p.first_name),
        player_last_name: max(p.last_name),
        player_ext_id: max(p.ext_person_id)
      },
      where: b.date_time > ^lower_date_bound,
      order_by: [asc: b.date_time, desc: p.ext_person_id],
      group_by: [p.ext_person_id, b.date_time]
    )
    |> Repo.all()
  end

  @doc """
  Creates a beef.

  ## Examples

      iex> create_beef(%{field: value})
      {:ok, %Beef{}}

      iex> create_beef(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_beef(attrs \\ %{}) do
    %Beef{}
    |> Beef.changeset(attrs)
    |> Repo.insert()
  end

  def upsert_beef(%{ext_game_id: ext_game_id, player_id: player_id} = attrs) do
    case Repo.get_by(Beef, ext_game_id: ext_game_id, player_id: player_id) do
      nil -> %Beef{}
      beef -> beef
    end
    |> Beef.changeset(attrs)
    |> Repo.insert_or_update()
  end

  @doc """
  Updates a beef.

  ## Examples

      iex> update_beef(beef, %{field: new_value})
      {:ok, %Beef{}}

      iex> update_beef(beef, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_beef(%Beef{} = beef, attrs) do
    beef
    |> Beef.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a beef.

  ## Examples

      iex> delete_beef(beef)
      {:ok, %Beef{}}

      iex> delete_beef(beef)
      {:error, %Ecto.Changeset{}}

  """
  def delete_beef(%Beef{} = beef) do
    Repo.delete(beef)
  end

  def delete_old_beef({:ok, %Beef{} = beef}) do
    Beef.delete_all_but_this_beef(beef)
  end

  def delete_old_beef({:error, _error} = error) do
    error
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking beef changes.

  ## Examples

      iex> change_beef(beef)
      %Ecto.Changeset{data: %Beef{}}

  """
  def change_beef(%Beef{} = beef, attrs \\ %{}) do
    Beef.changeset(beef, attrs)
  end

  def fetch_and_broadcast_games(games) do
    alias ClassicClips.BigBeef.Services.Stats

    games_info =
      Enum.filter(games, &GameData.should_fetch_game_data?/1)
      |> Enum.map(&get_game_data/1)
      |> Enum.filter(&(not is_nil(&1)))
      |> Enum.map(fn game ->
        %{
          home: home,
          away: away,
          game_status: game_status,
          game_time: game_time,
          game_start_time: game_start_time,
          game_id: game_id
        } = Stats.extract_team_stats(game)

        Enum.concat(Stats.extract_player_stats(home), Stats.extract_player_stats(away))
        |> Enum.map(&get_or_create_player(&1, game_time, game_id, game_start_time))

        make_game_data(game_id, game_start_time, game_status)
      end)

    get_recent_beefs() |> broadcast_beef(:new_beef)

    games_info
  end

  def get_game_data(%GameData{id: id}) do
    case ClassicClips.BigBeef.Services.Stats.get_boxscore_for_game(id) do
      {:ok, game} -> game
      {:error, _} -> nil
    end
  end

  defp make_game_data(id, game_start_time, status) do
    {:ok, start_time, _} = DateTime.from_iso8601(game_start_time)

    %GameData{
      id: id,
      start_time: start_time,
      status: status
    }
  end

  alias ClassicClips.BigBeef.Player

  @doc """
  Returns the list of players.

  ## Examples

      iex> list_players()
      [%Player{}, ...]

  """
  def list_players do
    Repo.all(Player)
  end

  @doc """
  Gets a single player.

  Raises `Ecto.NoResultsError` if the Player does not exist.

  ## Examples

      iex> get_player!(123)
      %Player{}

      iex> get_player!(456)
      ** (Ecto.NoResultsError)

  """
  def get_player!(id), do: Repo.get!(Player, id)

  @doc """
  Creates a player.

  ## Examples

      iex> create_player(%{field: value})
      {:ok, %Player{}}

      iex> create_player(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_player(attrs \\ %{}) do
    %Player{}
    |> Player.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a player.

  ## Examples

      iex> update_player(player, %{field: new_value})
      {:ok, %Player{}}

      iex> update_player(player, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_player(%Player{} = player, attrs) do
    player
    |> Player.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a player.

  ## Examples

      iex> delete_player(player)
      {:ok, %Player{}}

      iex> delete_player(player)
      {:error, %Ecto.Changeset{}}

  """
  def delete_player(%Player{} = player) do
    Repo.delete(player)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking player changes.

  ## Examples

      iex> change_player(player)
      %Ecto.Changeset{data: %Player{}}

  """
  def change_player(%Player{} = player, attrs \\ %{}) do
    Player.changeset(player, attrs)
  end

  def get_or_create_player(
        %{ext_person_id: ext_person_id} = player_data,
        game_time,
        game_id,
        game_start_time
      ) do
    {:ok, player} =
      case Repo.get_by(Player, ext_person_id: ext_person_id) do
        nil -> create_player(player_data)
        %Player{} = p -> {:ok, p}
      end

    beef_data =
      Map.merge(player_data, %{
        player_id: player.id,
        game_time: game_time,
        ext_game_id: game_id,
        date_time: game_start_time
      })

    upsert_beef(beef_data)
  end

  def subscribe_new_beef() do
    Phoenix.PubSub.subscribe(ClassicClips.PubSub, "new_beef")
  end

  def broadcast_beef(beefs, :new_beef) do
    Phoenix.PubSub.broadcast(ClassicClips.PubSub, "new_beef", {:new_beef, beefs})
  end

  alias ClassicClips.BigBeef.BigBeefEvent

  @doc """
  Returns the list of big_beef_events.

  ## Examples

      iex> list_big_beef_events()
      [%BigBeefEvent{}, ...]

  """
  def list_big_beef_events do
    from(bbe in BigBeefEvent,
      join: b in assoc(bbe, :beef),
      order_by: [desc: b.date_time],
      select: bbe
    )
    |> Repo.all()
    |> Repo.preload(beef: [:player])
  end

  @doc """
  Gets a single big_beef_event.

  Raises `Ecto.NoResultsError` if the Big beef event does not exist.

  ## Examples

      iex> get_big_beef_event!(123)
      %BigBeefEvent{}

      iex> get_big_beef_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_big_beef_event!(id), do: Repo.get!(BigBeefEvent, id)

  @doc """
  Creates a big_beef_event.

  ## Examples

      iex> create_big_beef_event(%{field: value})
      {:ok, %BigBeefEvent{}}

      iex> create_big_beef_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_big_beef_event(attrs \\ %{}) do
    %BigBeefEvent{}
    |> BigBeefEvent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a big_beef_event.

  ## Examples

      iex> update_big_beef_event(big_beef_event, %{field: new_value})
      {:ok, %BigBeefEvent{}}

      iex> update_big_beef_event(big_beef_event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_big_beef_event(%BigBeefEvent{} = big_beef_event, attrs) do
    big_beef_event
    |> BigBeefEvent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a big_beef_event.

  ## Examples

      iex> delete_big_beef_event(big_beef_event)
      {:ok, %BigBeefEvent{}}

      iex> delete_big_beef_event(big_beef_event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_big_beef_event(%BigBeefEvent{} = big_beef_event) do
    Repo.delete(big_beef_event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking big_beef_event changes.

  ## Examples

      iex> change_big_beef_event(big_beef_event)
      %Ecto.Changeset{data: %BigBeefEvent{}}

  """
  def change_big_beef_event(%BigBeefEvent{} = big_beef_event, attrs \\ %{}) do
    BigBeefEvent.changeset(big_beef_event, attrs)
  end
end
