defmodule PickEmWeb.PickEmLive.Leaders do
  use PickEmWeb, :live_view

  alias ClassicClips.{Repo, PickEm}
  alias ClassicClips.PickEm.{MatchUp, NdcPick, Team}

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = get_or_create_user(session)

    {:ok,
     socket
     |> assign(:total_picks_today, 0)
     |> assign(:leaders, get_leaders())
     |> assign(:user, user)}
  end

  def get_leaders() do
    PickEm.get_leaders()
  end

  def get_or_create_user(%{"profile" => profile}) do
    alias ClassicClips.Timeline.User

    case Repo.get_by(User, email: profile.email) do
      nil -> User.create_user(profile)
      %User{} = user -> {:ok, user}
    end
  end

  def get_or_create_user(_) do
    {:ok, nil}
  end
end
