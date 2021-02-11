defmodule ClassicClipsWeb.UserLive.Show do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.Timeline
  alias ClassicClips.Timeline.User
  alias ClassicClips.Repo

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = get_or_create_user(session)

    {:ok, assign(socket, :user, user) |> assign(:gooogle_auth_url, generate_oauth_url())}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:clip, Timeline.get_user!(id))}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp page_title(:show), do: "Show Clip"
  defp page_title(:edit), do: "Edit Clip"

  defp get_or_create_user(%{"profile" => profile}) do
    case Repo.get_by(User, email: profile.email) do
      nil -> User.create_user(profile)
      %User{} = user -> {:ok, user}
    end
  end

  defp get_or_create_user(_) do
    {:ok, nil}
  end

  defp generate_oauth_url do
    %{host: ClassicClipsWeb.Endpoint.host(), port: System.get_env("PORT", "4000")}
    |> ElixirAuthGoogle.generate_oauth_url()
  end
end
