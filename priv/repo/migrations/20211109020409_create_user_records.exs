defmodule ClassicClips.Repo.Migrations.CreateUserRecords do
  use Ecto.Migration

  def change do
    create table(:user_records, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :wins, :integer
      add :losses, :integer
      add :month, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :season_id, references(:seasons, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:user_records, [:user_id])
    create index(:user_records, [:season_id])
  end
end
