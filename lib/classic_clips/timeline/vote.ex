defmodule ClassicClips.Timeline.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "votes" do
    field :up, :boolean, default: false

    belongs_to :clip, ClassicClips.Timeline.Clip, type: :binary_id
    belongs_to :user, ClassicClips.Timeline.User, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [:clip_id, :user_id, :up])
    |> validate_required([:clip_id, :user_id, :up])
  end
end
