defmodule ClassicClips.BigBeef.Player do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "players" do
    field :first_name, :string
    field :last_name, :string
    field :number, :integer
    field :team, :string
    field :ext_person_id, :string

    has_many :beefs, ClassicClips.BigBeef.Beef

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(player, attrs) do
    player
    |> cast(attrs, [:first_name, :last_name, :number, :team, :ext_person_id])
    |> unique_constraint(:ext_person_id)
    |> validate_required([:first_name, :last_name, :number, :team, :ext_person_id])
  end
end
