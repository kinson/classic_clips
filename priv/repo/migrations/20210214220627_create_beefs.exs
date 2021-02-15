defmodule ClassicClips.Repo.Migrations.CreateBeefs do
  use Ecto.Migration

  def change do
    create table(:beefs, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :date_time, :utc_datetime
      add :beef_count, :integer
      add :ext_game_id, :string
      add :game_time, :integer

      timestamps(type: :utc_datetime)
    end
  end
end
