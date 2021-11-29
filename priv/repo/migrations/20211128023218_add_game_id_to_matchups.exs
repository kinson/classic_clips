defmodule ClassicClips.Repo.Migrations.AddGameIdToMatchups do
  use Ecto.Migration

  def change do
    alter table(:matchups) do
      add :nba_game_id, :string
    end
  end
end
