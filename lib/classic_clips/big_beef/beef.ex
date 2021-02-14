defmodule ClassicClips.BigBeef.Beef do
  use Ecto.Schema
  import Ecto.Changeset

  schema "beefs" do
    field :beef_count, :integer
    field :date_time, :string
    field :player, :string

    timestamps()
  end

  @doc false
  def changeset(beef, attrs) do
    beef
    |> cast(attrs, [:player, :date_time, :beef_count])
    |> validate_required([:player, :date_time, :beef_count])
  end
end
