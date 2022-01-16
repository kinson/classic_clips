defmodule ClassicClips.Repo.Migrations.AddEmailWhenMatchupCreated do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :email_new_matchups, :boolean, default: false
    end
  end
end
