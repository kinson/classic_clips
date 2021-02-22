defmodule ClassicClips.Repo.Migrations.CreateVideos do
  use Ecto.Migration

  def change do
    create table(:videos, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :publish_date, :string
      add :yt_video_id, :string
      add :yt_video_url, :string
      add :type, :string
      add :title, :string
      add :description, :string
      add :yt_thumbnail_url, :string

      timestamps(type: :utc_datetime)
    end

  end
end
