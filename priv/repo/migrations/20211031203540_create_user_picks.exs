defmodule ClassicClips.Repo.Migrations.CreateUserPicks do
  use Ecto.Migration

  def change do
    create table(:user_picks, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :result, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :matchup_id, references(:matchups, on_delete: :nothing, type: :binary_id)
      add :picked_team_id, references(:teams, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:user_picks, [:user_id])
    create index(:user_picks, [:matchup_id])
    create index(:user_picks, [:picked_team_id])
  end
end
