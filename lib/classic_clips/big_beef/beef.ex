defmodule ClassicClips.BigBeef.Beef do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias ClassicClips.BigBeef.Beef
  alias ClassicClips.Repo

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "beefs" do
    field :beef_count, :integer
    field :date_time, :utc_datetime
    field :ext_game_id, :string
    field :game_time, :integer

    belongs_to :player, ClassicClips.BigBeef.Player, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(beef, attrs) do
    beef
    |> cast(attrs, [:date_time, :beef_count, :game_time, :ext_game_id, :player_id])
    |> validate_required([:beef_count, :ext_game_id, :game_time, :player_id])
  end

  def delete_all_but_this_beef(%Beef{id: id, player_id: player_id, ext_game_id: ext_game_id}) do
    from(b in Beef,
      where: b.player_id == ^player_id,
      where: b.ext_game_id == ^ext_game_id,
      where: b.id != ^id,
      select: b
    ) |> Repo.delete_all()
  end
end
