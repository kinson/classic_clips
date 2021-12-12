defmodule ClassicClips.Repo.Migrations.CreateNdcRecords do
  use Ecto.Migration

  def change do
    create table(:ndc_records, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :month, :string, null: false
      add :leigh_wins, :integer, default: 0
      add :leigh_losses, :integer, default: 0
      add :skeets_wins, :integer, default: 0
      add :skeets_losses, :integer, default: 0
      add :tas_wins, :integer, default: 0
      add :tas_losses, :integer, default: 0
      add :trey_wins, :integer, default: 0
      add :trey_losses, :integer, default: 0

      add :latest_matchup_id, references(:matchups, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:ndc_records, [:latest_matchup_id])
  end
end
