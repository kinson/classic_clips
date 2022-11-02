defmodule ClassicClips.Repo.Migrations.AddSeasonIdToMatchup do
  use Ecto.Migration

  def change do
    alter table(:matchups) do
      add :season_id, references(:seasons, type: :binary_id)
    end
  end
end
