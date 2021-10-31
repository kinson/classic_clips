defmodule ClassicClips.Repo.Migrations.CreateTeams do
  use Ecto.Migration

  def change do
    create table(:teams, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :abbreviation, :string
      add :location, :string
      add :name, :string

      timestamps()
    end
  end
end
