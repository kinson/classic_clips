defmodule ClassicClips.Repo.Migrations.AddUserRoles do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :role, :string, default: "sicko"
    end
  end
end
