defmodule ClassicClips.Repo.Migrations.CreateMatchUps do
  use Ecto.Migration

  def change do
    create table(:matchups, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :tip_datetime, :utc_datetime
      add :spread, :string
      add :score, :string
      add :month, :string
      add :away_team_id, references(:teams, on_delete: :nothing, type: :binary_id)
      add :home_team_id, references(:teams, on_delete: :nothing, type: :binary_id)
      add :favorite_team_id, references(:teams, on_delete: :nothing, type: :binary_id)
      add :winning_team_id, references(:teams, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:matchups, [:away_team_id])
    create index(:matchups, [:home_team_id])
    create index(:matchups, [:favorite_team_id])
    create index(:matchups, [:winning_team_id])
  end
end
