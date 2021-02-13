defmodule ClassicClips.Timeline.Save do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "saves" do
    belongs_to :clip, ClassicClips.Timeline.Clip, type: :binary_id
    belongs_to :user, ClassicClips.Timeline.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(save, attrs) do
    save
    |> cast(attrs, [:clip_id, :user_id])
    |> validate_required([:clip_id, :user_id])
  end
end
