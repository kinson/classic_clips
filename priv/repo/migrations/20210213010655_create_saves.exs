defmodule ClassicClips.Repo.Migrations.CreateSaves do
  use Ecto.Migration

  def change do
    create table(:saves, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :clip_id, references("clips", type: :binary_id)
      add :user_id, references("users", type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:saves, [:clip_id, :user_id])
  end
end
