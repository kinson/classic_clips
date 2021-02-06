defmodule ClassicClipsWeb.ClipLive.Index do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.{Repo, Timeline}
  alias ClassicClips.Timeline.{Clip, User}

  @google_auth_url "https://accounts.google.com/o/oauth2/v2/auth?response_type=code"

  @impl true
  def mount(_params, session, socket) do
    user = get_or_create_user(session)

    modified_socket =
      socket
      |> assign(:user, user)
      |> assign(:clips, list_clips())
      |> assign(:gooogle_auth_url, generate_oauth_url())

    IO.inspect modified_socket.assigns

    {:ok, modified_socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Clip")
    |> assign(:clip, Timeline.get_clip!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Clip")
    |> assign(:clip, %Clip{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Clips")
    |> assign(:clip, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    clip = Timeline.get_clip!(id)
    {:ok, _} = Timeline.delete_clip(clip)

    {:noreply, assign(socket, :clips, list_clips())}
  end

  defp list_clips do
    Timeline.list_clips()
  end

  defp generate_oauth_url do
    client_id = System.get_env("GOOGLE_CLIENT_ID")
    scope = System.get_env("GOOGLE_SCOPE") || "profile email"

    redirect_uri = "http://localhost:4000/auth/google/callback"
    "#{@google_auth_url}&client_id=#{client_id}&scope=#{scope}&redirect_uri=#{redirect_uri}"
  end

  defp get_or_create_user(%{"profile" => profile}) do
    case Repo.get_by(User, email: profile.email) do
      nil -> User.create_user(profile)
      %User{} = user -> user
    end
  end

  defp get_or_create_user(_) do
    nil
  end
end
