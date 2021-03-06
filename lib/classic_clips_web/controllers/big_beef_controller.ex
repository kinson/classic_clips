defmodule ClassicClipsWeb.BigBeefController do
  use ClassicClipsWeb, :controller

  def previous_beef(conn, _params) do
    big_beefs = ClassicClips.BigBeef.list_big_beef_events()

    assign(conn, :big_beefs, big_beefs)
    |> assign(:page_title, "BIG BEEF ARCHIVE")
    |> render(:index)
  end
end
