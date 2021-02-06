defmodule ClassicClips.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :clip_id, references("clips", type: :binary_id)
      add :user_id, references("users", type: :binary_id)
      add :up, :boolean, default: true, null: false

      timestamps()
    end

  end
end
