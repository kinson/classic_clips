defmodule PickEmWeb.PickEmLive.Leaders do
  use PickEmWeb, :live_view

  alias ClassicClips.{Repo, PickEm}
  alias ClassicClips.PickEm.{MatchUp, NdcPick, UserPick, Team}

  @impl true
  def mount(_params, session, socket) do
    socket = socket |> assign(:total_picks_today, 0) |> assign(:leaders, get_leaders())
    {:ok, socket}
  end

  def get_leaders() do
    PickEm.get_leaders() |> IO.inspect()
  end
end
