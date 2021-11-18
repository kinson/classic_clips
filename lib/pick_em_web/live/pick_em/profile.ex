defmodule PickEmWeb.PickEmLive.Profile do
  use PickEmWeb, :live_view

  alias ClassicClips.Repo
  alias ClassicClips.PickEm.{MatchUp, NdcPick, UserPick, Team}

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = get_or_create_user(session)

    if is_nil(user) do
      {:ok, push_redirect(socket, to: "/")}
    else
      {:ok, socket |> assign(:total_picks_today, 0) |> assign(:user, user)}
    end
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
