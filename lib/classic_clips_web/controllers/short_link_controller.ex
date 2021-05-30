defmodule ClassicClipsWeb.ShortLinkController do
  use ClassicClipsWeb, :controller

  import Ecto.Query, only: [from: 2]
  alias ClassicClips.Repo
  alias ClassicClips.Timeline.Clip

  def index(conn, %{"slug" => slug}) do
    search = "%#{slug}%"

    clips =
      from(c in Clip,
        where: ilike(fragment("CAST(? AS VARCHAR(36))", field(c, :id)), ^search),
        order_by: [desc: c.inserted_at, asc: c.id]
      )
      |> Repo.all()

    clip_id =
      case clips do
        [] -> "none"
        [clip | _] -> clip.id
      end

    redirect(conn, to: "/clips/#{clip_id}")
  end

  def index(conn, _params) do
    redirect(conn, to: "/")
  end
end
