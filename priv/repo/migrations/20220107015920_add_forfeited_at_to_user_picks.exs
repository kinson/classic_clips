defmodule ClassicClips.Repo.Migrations.AddForfeitedAtToUserPicks do
  use Ecto.Migration

  def change do
    alter table(:user_picks) do
      add :forfeited_at, :utc_datetime
    end
  end
end
