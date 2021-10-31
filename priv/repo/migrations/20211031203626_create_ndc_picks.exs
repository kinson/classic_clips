defmodule ClassicClips.Repo.Migrations.CreateNdcPicks do
  use Ecto.Migration

  def change do
    create table(:ndc_picks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :matchup_id, references(:matchups, on_delete: :nothing, type: :binary_id)
      add :skeets_pick_team_id, references(:teams, on_delete: :nothing, type: :binary_id)
      add :tas_pick_team_id, references(:teams, on_delete: :nothing, type: :binary_id)
      add :leigh_pick_team_id, references(:teams, on_delete: :nothing, type: :binary_id)
      add :trey_pick_team_id, references(:teams, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:ndc_picks, [:matchup_id])
    create index(:ndc_picks, [:skeets_pick_team_id])
    create index(:ndc_picks, [:tas_pick_team_id])
    create index(:ndc_picks, [:leigh_pick_team_id])
    create index(:ndc_picks, [:trey_pick_team_id])
  end
end
