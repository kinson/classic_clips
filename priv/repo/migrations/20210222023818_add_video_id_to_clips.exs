defmodule ClassicClips.Repo.Migrations.AddVideoIdToClips do
  use Ecto.Migration

  def change do
    alter table(:clips) do
      add :video_id, references(:videos, type: :binary_id)
    end
  end
end
