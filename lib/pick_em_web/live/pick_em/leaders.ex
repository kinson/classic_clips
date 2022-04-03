defmodule PickEmWeb.PickEmLive.Leaders do
  use PickEmWeb, :live_view

  alias ClassicClips.PickEm
  alias PickEmWeb.PickEmLive.{Theme, User}
  alias ClassicClips.BigBeef.Season

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = User.get_or_create_user(session)

    theme = Theme.get_theme_from_session(session)

    {:ok,
     socket
     |> assign(:page, "leaders")
     |> assign(:theme, theme)
     |> assign(:leaders_seasons, PickEm.get_months_seasons_for_leaders_cached())
     |> assign(:user, user)}
  end

  @impl true
  def handle_params(%{"month" => month, "season" => season_year_end}, _, socket) do
    season = PickEm.get_season_by_year_end_cached(season_year_end)

    {:noreply,
     socket
     |> assign(:leaders, PickEm.get_leaders_cached(season, month))
     |> assign(:selected_month, month)
     |> assign(:selected_season, season)}
  end

  def handle_params(_, _, socket) do
    current_season = PickEm.get_current_season_cached()
    current_month = PickEm.get_current_month_name()

    {:noreply,
     socket
     |> assign(:leaders, PickEm.get_leaders_cached(current_season, current_month))
     |> assign(:selected_month, current_month)
     |> assign(:selected_season, current_season)}
  end

  defp get_truncated_username(%ClassicClips.Timeline.User{username: username}) do
    if String.length(username) > 22 do
      truncated = String.slice(username, 0..19) |> String.trim_trailing()

      "#{truncated}..."
    else
      username
    end
  end

  defp page_title(%{current: true} = _season, month) do
    "#{String.capitalize(month)} Leaders"
  end

  defp page_title(%Season{name: name}, month) when is_binary(month) do
    "#{String.capitalize(month)} #{name} Leaders"
  end

  defp page_title(_, _) do
    "Pick 'Em Leaders"
  end
end
