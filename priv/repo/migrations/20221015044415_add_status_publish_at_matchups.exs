defmodule ClassicClips.Repo.Migrations.AddStatusPublishAtMatchups do
  use Ecto.Migration

  def change do
    alter table(:matchups) do
      add :status, :string
      add :publish_at, :utc_datetime
    end
  end
end
