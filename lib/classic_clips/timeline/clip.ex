defmodule ClassicClips.Timeline.Clip do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clips" do
    field :start_time, :integer
    field :title, :string
    field :video_ext_id, :string

    timestamps()
  end

  @doc false
  def changeset(clip, attrs) do
    clip
    |> cast(attrs, [:video_ext_id, :start_time, :title])
    |> validate_required([:video_ext_id, :start_time, :title])
  end
end
