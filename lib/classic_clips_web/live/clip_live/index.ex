defmodule ClassicClipsWeb.ClipLive.Index do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.{Repo, Timeline}
  alias ClassicClips.Timeline.{Clip, User}

  @google_auth_url "https://accounts.google.com/o/oauth2/v2/auth?response_type=code"

  @impl true
  def mount(_params, session, socket) do
    if connected?(socket), do: Timeline.subscribe()

    {:ok, user} = get_or_create_user(session)

    modified_socket =
      socket
      |> assign(:user, user)
      |> assign(:clips, list_top_clips())
      |> assign(:votes, get_user_votes(user))
      |> assign(:gooogle_auth_url, generate_oauth_url())

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

    {:noreply, assign(socket, :clips, list_top_clips())}
  end

  def handle_event("change_sort", %{"sort" => %{"timeframe" => "new"}}, socket) do
    {:noreply, assign(socket, :clips, list_new_clips())}
  end

  def handle_event("change_sort", %{"sort" => %{"timeframe" => sort_timeframe}}, socket) do
    {:noreply, assign(socket, :clips, list_top_clips(sort_timeframe))}
  end

  def handle_event(
        "inc_votes",
        %{"clip" => clip_id},
        %{assigns: %{votes: votes, user: user}} = socket
      ) do
    case Timeline.can_vote?(clip_id, votes, user) do
      true ->
        {:noreply, socket}

      false ->
        {:ok, vote} = ClassicClips.Timeline.inc_votes(clip_id, user)
        {:noreply, assign(socket, :votes, [vote | votes])}
    end
  end

  @impl true
  # def handle_info({:clip_created, clip}, socket) do
  #   {:noreply, update(socket, :clips, fn clips -> clips end)}
  # end

  def handle_info({:clip_updated, clip}, socket) do
    {:noreply,
     update(socket, :clips, fn clips ->
       Enum.map(clips, &if(&1.id == clip.id, do: clip, else: &1))
     end)}
  end

  defp list_top_clips do
    list_top_clips("today")
  end

  defp list_top_clips(timeframe) do
    Timeline.list_top_clips_by_date(timeframe)
  end

  defp list_new_clips() do
    Timeline.list_newest_clips()
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
      %User{} = user -> {:ok, user}
    end
  end

  defp get_or_create_user(_) do
    {:ok, nil}
  end

  defp get_user_votes(nil), do: []

  defp get_user_votes(%User{} = user) do
    Timeline.list_votes_for_user(user)
  end
end
