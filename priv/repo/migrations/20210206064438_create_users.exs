defmodule ClassicClips.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :username, :string, null: false
      add :email, :string
      add :google_id, :string
      add :active, :boolean, default: true, null: false

      timestamps()
    end

    alter table(:clips) do
      add :user_id, references("users", type: :binary_id)
    end
  end
end
