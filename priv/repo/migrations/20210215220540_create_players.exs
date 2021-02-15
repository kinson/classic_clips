defmodule ClassicClips.Repo.Migrations.CreatePlayers do
  use Ecto.Migration

  def change do
    create table(:players, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :first_name, :string
      add :last_name, :string
      add :number, :integer
      add :team, :string
      add :ext_person_id, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:players, :ext_person_id)

    alter table(:beefs) do
      add :player_id, references("players", type: :binary_id)
    end
  end
end
