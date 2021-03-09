defmodule ClassicClips.Repo.Migrations.MakeYtVideoIdUnique do
  use Ecto.Migration

  def change do
    create unique_index(:videos, :yt_video_id)

    alter table(:videos) do
      add :thumbnails, :map
      remove :yt_thumbnail_url
    end
  end
end
