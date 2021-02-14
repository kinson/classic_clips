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
end
