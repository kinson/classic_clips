defmodule ClassicClips.Repo.Migrations.AddScheduledGamesTable do
  use Ecto.Migration

  def change do
    create table(:scheduled_games, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :away_team_id, references(:teams, on_deleted: :nothing, type: :binary_id)
      add :home_team_id, references(:teams, on_deleted: :nothing, type: :binary_id)
      add :season_id, references(:seasons, on_deleted: :nothing, type: :binary_id)

      add :external_id, :string
      add :date, :date
      add :start_time_et, :string
      add :dt_utc, :naive_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:scheduled_games, [:date])
    create index(:scheduled_games, [:external_id], unique: true)
  end
end
