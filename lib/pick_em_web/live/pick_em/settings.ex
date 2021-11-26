defmodule PickEmWeb.PickEmLive.Settings do
  use PickEmWeb, :live_view

  alias ClassicClips.{Repo, PickEm}
  alias ClassicClips.PickEm.{MatchUp, NdcPick, Team}

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = get_or_create_user(session)

    connection_params = get_connect_params(socket) || %{}

    theme =
      connection_params
      |> Map.get("theme", "{}")
      |> Jason.decode!()

    {:ok,
     socket
     |> assign(:east_teams, get_east_teams())
     |> assign(:theme_data, "{}")
     |> assign(:theme, theme)
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
    theme =
      form_data
      |> Map.delete("_csrf_token")
      |> ClassicClips.PickEm.get_custom_team_emojis(
        socket.assigns.east_teams ++ socket.assigns.west_teams
      )

    {:noreply,
     socket
     |> assign(:is_editing_teams, false)
     |> assign(:theme, theme)
     |> assign(:theme_data, Jason.encode!(theme))}
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

  def get_emoji_for_team(team, nil), do: team.default_emoji

  def get_emoji_for_team(team, theme) do
    Map.get(theme, team.id, team.default_emoji)
  end
end
