defmodule ClassicClips.Repo.Migrations.CreateClipsTags do
  use Ecto.Migration

  def change do
    create table(:clips_tags, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :clip_id, references(:clips, type: :binary_id)
      add :tag_id, references(:tags, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

  end
end
