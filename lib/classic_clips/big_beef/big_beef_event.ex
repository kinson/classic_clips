defmodule ClassicClips.BigBeef.BigBeefEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "big_beef_events" do
    field :box_score_url, :string, default: "notyet"
    field :yt_highlight_video_url, :string, default: "notyet"

    belongs_to :beef, ClassicClips.BigBeef.Beef, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(big_beef_event, attrs) do
    big_beef_event
    |> cast(attrs, [:box_score_url, :yt_highlight_video_url, :beef_id])
    |> validate_required([:beef_id])
  end
end
