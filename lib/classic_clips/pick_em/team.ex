defmodule ClassicClips.PickEm.Team do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "teams" do
    field :abbreviation, :string
    field :location, :string
    field :name, :string
    field :conference, Ecto.Enum, values: [:east, :west]
    field :default_emoji, :string

    timestamps()
  end

  @doc false
  def changeset(team, attrs) do
    team
    |> cast(attrs, [:abbreviation, :location, :name, :conference, :default_emoji])
    |> validate_required([:abbreviation, :location, :name, :conference, :default_emoji])
  end
end
