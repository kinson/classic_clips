defmodule ClassicClips.Repo.Migrations.AddUniqueIndicies do
  use Ecto.Migration

  def change do
    # clips indicies
    create unique_index(:clips, [:title, :user_id])

    # votes indicies
    create unique_index(:votes, [:clip_id, :user_id])

    # users indicies
    create unique_index(:users, :google_id)
    create unique_index(:users, :username)
    create unique_index(:users, :email)
  end
end
