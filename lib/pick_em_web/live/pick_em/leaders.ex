defmodule PickEmWeb.PickEmLive.Leaders do
  use PickEmWeb, :live_view

  alias ClassicClips.PickEm
  alias PickEmWeb.PickEmLive.{Theme, User}

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = User.get_or_create_user(session)

    theme = Theme.get_theme_from_session(session)

    {:ok,
     socket
     |> assign(:page, "leaders")
     |> assign(:theme, theme)
     |> assign(:total_picks_today, 0)
     |> assign(:leaders, get_leaders())
     |> assign(:user, user)}
  end

  defp get_leaders do
    PickEm.get_leaders_cached()
  end

  defp get_truncated_username(%ClassicClips.Timeline.User{username: username}) do
    if String.length(username) > 22 do
      truncated = String.slice(username, 0..19) |> String.trim_trailing()

      "#{truncated}..."
    else
      username
    end
  end
end
