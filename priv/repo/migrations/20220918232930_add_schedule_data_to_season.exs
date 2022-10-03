defmodule ClassicClips.Repo.Migrations.AddScheduleDataToSeason do
  use Ecto.Migration

  def change do
    alter table(:seasons) do
      add :schedule, :map, null: false, default: %{}
    end
  end
end
