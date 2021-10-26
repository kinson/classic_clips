defmodule ClassicClips.Repo.Migrations.MakeSeasons do
  use Ecto.Migration

  def change do
    create table(:seasons, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :year_start, :integer
      add :year_end, :integer
      add :name, :string

      timestamps(type: :utc_datetime)
    end

    alter table(:beefs) do
      add :season_id, references(:seasons, type: :binary_id)
    end

    create index(:beefs, :season_id)
    create unique_index(:seasons, :name)
    create unique_index(:seasons, [:year_start, :year_end])
  end
end
