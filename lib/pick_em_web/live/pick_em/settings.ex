defmodule PickEmWeb.PickEmLive.Settings do
  use PickEmWeb, :live_view

  alias ClassicClips.{Repo, PickEm}
  alias ClassicClips.PickEm.{MatchUp, NdcPick, Team}

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = get_or_create_user(session)

    {:ok,
     socket
     |> assign(:east_teams, get_east_teams())
     |> assign(:west_teams, get_west_teams())
     |> assign(:is_editing_teams, false)
     |> assign(:user, user)}
  end

  @impl true
  def handle_event("edit", _, socket) do
    {:noreply, assign(socket, :is_editing_teams, true)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, :is_editing_teams, false)}
  end

  def handle_event("save_emojis", form_data, socket) do
    ClassicClips.PickEm.save_user_team_emojis(
      Map.delete(form_data, "_csrf_token"),
      socket.assigns.east_teams ++ socket.assigns.west_teams
    )

    {:noreply, assign(socket, :is_editing_teams, false)}
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

  def get_east_teams() do
    PickEm.get_teams_for_conference(:east)
  end

  def get_west_teams() do
    PickEm.get_teams_for_conference(:west)
  end
end
