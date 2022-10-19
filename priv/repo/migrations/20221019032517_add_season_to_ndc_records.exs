defmodule ClassicClips.Repo.Migrations.AddSeasonToNdcRecords do
  use Ecto.Migration

  def change do
    alter table(:ndc_records) do
      add :season_id, references(:seasons, type: :binary_id)
    end
  end
end
