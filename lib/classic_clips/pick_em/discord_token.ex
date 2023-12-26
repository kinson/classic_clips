defmodule ClassicClips.PickEm.DiscordToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "discord_tokens" do
    field :access_token, :string
    field :refresh_token, :string
    field :expires_at, :utc_datetime

    field :webhook_channel_id, :string
    field :webhook_server_id, :string
    field :webhook_url, :string
    field :webhook_token, :string
    field :webhook_id, :string

    timestamps()
  end

  @doc false
  def changeset(discord_token, attrs) do
    discord_token
    |> cast(attrs, [
      :access_token,
      :refresh_token,
      :expires_at,
      :webhook_token,
      :webhook_url,
      :webhook_server_id,
      :webhook_channel_id,
      :webhook_id
    ])
  end
end
