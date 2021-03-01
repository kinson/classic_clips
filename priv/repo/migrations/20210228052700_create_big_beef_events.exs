defmodule ClassicClips.Repo.Migrations.CreateBigBeefEvents do
  use Ecto.Migration

  def change do
    create table(:big_beef_events, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :box_score_url, :string
      add :yt_highlight_video_url, :string
      add :beef_id, references(:beefs, type: :binary_id)

      timestamps(type: :utc_datetime)
    end
  end
end
