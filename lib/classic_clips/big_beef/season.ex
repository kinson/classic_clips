defmodule ClassicClips.BigBeef.Season do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "seasons" do
    field :year_start, :integer
    field :year_end, :integer
    field :name, :string
    field :current, :boolean
    field :schedule, :map

    has_many :beefs, ClassicClips.BigBeef.Beef

    timestamps(type: :utc_datetime)
  end

  def changeset(season, attrs) do
    season
    |> cast(attrs, [:year_start, :year_end, :name, :current])
    |> validate_required([:year_start, :year_end, :name])
  end
end
