defmodule PickEmWeb.PickEmLive.Profile do
  use PickEmWeb, :live_view

  alias ClassicClips.Repo
  alias ClassicClips.PickEm.{MatchUp, NdcPick, UserPick, Team}

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = get_or_create_user(session)

    connection_params = get_connect_params(socket) || %{}

    theme =
      case Map.get(connection_params, "theme") do
        nil -> nil
        data -> Jason.decode!(data)
      end

    if is_nil(user) do
      {:ok, push_redirect(socket, to: "/")}
    else
      {:ok,
       socket
       |> assign(:page, "profile")
       |> assign(:theme, theme)
       |> assign(:total_picks_today, 0)
       |> assign(:user, user)}
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
