defmodule ClassicClips.Repo.Migrations.CreateClips do
  use Ecto.Migration

  def change do
    create table(:clips, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :yt_video_url, :string, null: false
      add :yt_thumbnail_url, :string, null: false
      add :clip_length, :integer

      timestamps(type: :utc_datetime)
    end

  end
end
