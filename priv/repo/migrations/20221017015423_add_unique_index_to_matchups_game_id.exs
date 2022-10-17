defmodule ClassicClips.Repo.Migrations.AddUniqueIndexToMatchupsGameId do
  use Ecto.Migration

  def change do
    create unique_index(:matchups, [:nba_game_id])
  end
end
