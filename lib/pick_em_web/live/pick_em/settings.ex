defmodule PickEmWeb.PickEmLive.Settings do
  use PickEmWeb, :live_view

  alias ClassicClips.{PickEm}
  alias PickEmWeb.PickEmLive.{Theme, User}

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = User.get_or_create_user(session)

    theme = Theme.get_theme_from_session(session)

    {:ok,
     socket
     |> assign(:page, "settings")
     |> assign(:east_teams, get_east_teams())
     |> assign(:theme_data, Jason.encode!(theme))
     |> assign(:theme, theme)
     |> assign(:west_teams, get_west_teams())
     |> assign(:is_editing_teams, false)
     |> assign(:submit_emoji_enabled, false)
     |> assign(:user, user)}
  end

  @impl true
  def handle_event("edit", _, socket) do
    {:noreply, assign(socket, :is_editing_teams, true)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, :is_editing_teams, false)}
  end

  def handle_event(
        "toggle_emojis",
        %{"team_emojis" => team_emojis},
        socket
      ) do
    theme =
      socket.assigns.theme
      |> Map.merge(team_emojis)

    {:noreply,
     socket
     |> assign(:is_editing_teams, false)
     |> assign(:submit_emoji_enabled, true)
     |> assign(:theme, theme)
     |> assign(:theme_data, Jason.encode!(theme))
     |> PickEmWeb.PickEmLive.NotificationComponent.show("Updated emoji preference")}
  end

  defp get_east_teams do
    PickEm.get_cached_teams_for_conference(:east)
  end

  defp get_west_teams do
    PickEm.get_cached_teams_for_conference(:west)
  end
end
