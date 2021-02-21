defmodule ClassicClips.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string
      add :code, :string
      add :type, :string
      add :enabled, :boolean, default: true

      timestamps(type: :utc_datetime)
    end

  end
end
