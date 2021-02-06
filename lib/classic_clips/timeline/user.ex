defmodule ClassicClips.Timeline.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :active, :boolean, default: false
    field :email, :string
    field :username, :string
    field :google_id, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :active])
    |> validate_required([:username, :email, :active])
  end
end
