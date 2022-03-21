defmodule ClassicClips.Repo.Migrations.CreateTwitterTokenTable do
  use Ecto.Migration

  def change do
    create table(:twitter_tokens, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :access_token, :string
      add :refresh_token, :string
      add :expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
