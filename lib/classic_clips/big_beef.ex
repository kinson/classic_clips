defmodule ClassicClips.BigBeef do
  @moduledoc """
  The BigBeef context.
  """

  import Ecto.Query, warn: false
  alias ClassicClips.Repo

  alias ClassicClips.BigBeef.Beef

  @doc """
  Returns the list of beefs.

  ## Examples

      iex> list_beefs()
      [%Beef{}, ...]

  """
  def list_beefs do
    Repo.all(Beef)
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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking beef changes.

  ## Examples

      iex> change_beef(beef)
      %Ecto.Changeset{data: %Beef{}}

  """
  def change_beef(%Beef{} = beef, attrs \\ %{}) do
    Beef.changeset(beef, attrs)
  end

  def get_games() do
    alias ClassicClips.BigBeef.Services.Stats

    Stats.games_or_someshit()
    |> Enum.map(&Stats.get_boxscore_for_game/1)
    |> Enum.map(fn game ->
      %{home: home, away: away} = Stats.extract_team_stats(game)

      Enum.concat(Stats.extract_team_stats(home), Stats.extract_team_stats(away))
    end)
  end

  def get_test_game() do
    alias ClassicClips.BigBeef.Services.Stats

    game_id = "0022000413"

    {:ok, game} = Stats.get_boxscore_for_game(game_id)

    %{home: home, away: away, game_time: game_time} = Stats.extract_team_stats(game)

    Enum.concat(Stats.extract_player_stats(home), Stats.extract_player_stats(away))
    |> Enum.map(&get_or_create_player(&1, game_time, game_id))
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

  def get_or_create_player(%{ext_person_id: ext_person_id} = player_data, game_time, game_id) do
    {:ok, player} =
      case Repo.get_by(Player, ext_person_id: ext_person_id) do
        nil -> create_player(player_data)
        %Player{} = p -> {:ok, p}
      end

    beef_data =
      Map.merge(player_data, %{player_id: player.id, game_time: game_time, ext_game_id: game_id})

    create_beef(beef_data)
  end
end
