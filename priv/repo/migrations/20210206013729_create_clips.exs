defmodule ClassicClips.Repo.Migrations.CreateClips do
  use Ecto.Migration

  def change do
    create table(:clips) do
      add :video_ext_id, :string
      add :start_time, :integer
      add :title, :string

      timestamps()
    end

  end
end
