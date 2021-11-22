defmodule ClassicClips.Repo.Migrations.AddConferencesToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :conference, :string
    end
  end
end
