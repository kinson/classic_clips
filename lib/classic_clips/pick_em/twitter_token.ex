defmodule ClassicClips.PickEm.TwitterToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "twitter_tokens" do
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(twitter_token, attrs) do
    twitter_token
    |> cast(attrs, [:access_token, :refresh_token, :expires_at])
  end
end
