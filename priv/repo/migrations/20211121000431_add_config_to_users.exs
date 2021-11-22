defmodule ClassicClips.Repo.Migrations.AddConfigToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :config, :map, null: false, default: %{}
    end
  end
end
