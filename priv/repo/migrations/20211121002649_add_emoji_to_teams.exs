defmodule ClassicClips.Repo.Migrations.AddEmojiToTeams do
  use Ecto.Migration

  def change do
    alter table(:teams) do
      add :default_emoji, :string
    end
  end
end
