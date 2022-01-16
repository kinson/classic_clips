defmodule ClassicClips.Timeline.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias ClassicClips.Timeline.User
  alias ClassicClips.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :active, :boolean, default: true
    field :email, :string
    field :username, :string
    field :google_id, :string
    field :config, :map
    field :email_new_matchups, :boolean
    field :role, Ecto.Enum, values: [:sicko, :super_sicko], default: :sicko

    timestamps()
  end

  def create_user(attrs) do
    [username, _rest] = String.split(attrs.email, "@")
    email_as_initial_user_name = Map.put(attrs, :username, username)

    %User{}
    |> create_user_changeset(email_as_initial_user_name)
    |> Repo.insert(returning: true)
  end

  def create_user_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :active, :google_id, :email_new_matchups])
    |> put_change(:google_id, user.google_id || attrs.sub)
    |> validate_required([:email])
    |> unsafe_validate_unique(:username, Repo, message: "Username is already taken")
    |> validate_format(:username, ~r/[0-9a-zA-Z-_]+$/,
      message: "Username can only contain letters, numbers, underscores, and dashes"
    )
    |> unique_constraint(:email, message: "This email is being used by another account")
    |> unique_constraint(:google_id,
      message: "This Google Account is already associated with another account"
    )
    |> unsafe_validate_unique(:username, Repo, message: "Username is already taken")
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :active, :google_id, :email_new_matchups])
    |> put_change(:google_id, user.google_id || attrs.sub)
    |> validate_required([:email])
    |> validate_length(:username,
      min: 3,
      max: 30,
      message: "Username must be between 3 and 30 characters"
    )
    |> validate_format(:username, ~r/[0-9a-zA-Z-_]+$/,
      message: "Username can only contain letters, numbers, underscores, and dashes"
    )
    |> unique_constraint(:email, message: "This email is being used by another account")
    |> unique_constraint(:google_id,
      message: "This Google Account is already associated with another account"
    )
    |> unsafe_validate_unique(:username, Repo, message: "Username is already taken")
  end
end
