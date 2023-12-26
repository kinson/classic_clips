defmodule ClassicClips.Repo.Migrations.AddDiscordTokensTable do
  use Ecto.Migration

  def change do
    create table(:discord_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :access_token, :string
      add :refresh_token, :string
      add :expires_at, :utc_datetime

      add :webhook_channel_id, :string
      add :webhook_server_id, :string
      add :webhook_url, :string
      add :webhook_token, :string
      add :webhook_id, :string

      timestamps(type: :utc_datetime)
    end
  end
end
