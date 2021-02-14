defmodule ClassicClips.Repo.Migrations.CreateBeefs do
  use Ecto.Migration

  def change do
    create table(:beefs) do
      add :player, :string
      add :date_time, :utc_datetime
      add :beef_count, :integer

      timestamps(type: :utc_datetime)
    end

  end
end
