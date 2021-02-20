defmodule ClassicClips.Repo.Migrations.AddDeletedToClips do
  use Ecto.Migration

  def change do
    alter table(:clips) do
      add :deleted, :boolean, default: false
    end
  end
end
