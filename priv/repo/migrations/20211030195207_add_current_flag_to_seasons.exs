defmodule ClassicClips.Repo.Migrations.AddCurrentFlagToSeasons do
  use Ecto.Migration

  def change do
    alter table(:seasons) do
      add :current, :boolean, default: false
    end
  end
end
