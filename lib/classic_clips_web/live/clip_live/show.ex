defmodule ClassicClipsWeb.ClipLive.Show do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.{Timeline}
  alias ClassicClips.Timeline.{Clip}
  alias ClassicClips.Classics.Video

  @impl true
  def mount(%{"id" => id}, session, socket) do
    {:ok, user} = get_or_create_user(session)

    clip = Timeline.get_clip(id)

    modified_socket =
      socket
      |> assign(:page_title, "Classic Clips")
      |> assign(:clip, clip)
      |> page_metadata()
      |> assign(:show_signup_message, false)
      |> assign(:user, user)
      |> assign(:votes, get_user_votes(user))
      |> assign(:saves, get_user_saves(user))
      |> assign(:thumbs_up_total, get_user_thumbs_up(user))
      |> assign(:google_auth_url, generate_oauth_url())

    {:ok, modified_socket}
  end

  @impl true
  def handle_event(
        "inc_votes",
        _,
        %{assigns: %{user: nil}} = socket
      ) do
    {:noreply, assign(socket, :show_signup_message, true)}
  end

  def handle_event(
        "inc_votes",
        %{"clip" => clip_id},
        %{assigns: %{votes: votes, user: user}} = socket
      ) do
    case Timeline.can_vote?(clip_id, votes, user) do
      true ->
        {:ok, vote} = ClassicClips.Timeline.inc_votes(clip_id, user)
        {:noreply, assign(socket, :votes, [vote | votes])}

      false ->
        {:noreply, socket}
    end
  end

  def handle_event("save_clip", _, %{assigns: %{user: nil}} = socket) do
    {:noreply, assign(socket, :show_signup_message, true)}
  end

  def handle_event(
        "save_clip",
        %{"clip" => clip_id},
        %{
          assigns: %{
            saves: saves,
            user: user
          }
        } = socket
      ) do
    {:ok, new_saves} = update_saves(saves, clip_id, user.id)

    {:noreply, assign(socket, :saves, new_saves)}
  end

  def handle_event("hide_signup_message", _, socket) do
    {:noreply, assign(socket, :show_signup_message, false)}
  end

  @impl true
  def handle_info({:clip_created, clip}, socket) do
    old_clips = Enum.take(socket.assigns.clips, 11)

    {:noreply, assign(socket, :clips, [clip | old_clips])}
  end

  def handle_info({:clip_updated, clip}, socket) do
    {:noreply,
     update(socket, :clips, fn clips ->
       Enum.map(clips, &if(&1.id == clip.id, do: clip, else: &1))
     end)}
  end

  defp update_saves(saves, clip_id, user_id) do
    case Enum.find(saves, &(clip_id == &1.clip_id)) do
      nil -> add_save(saves, clip_id, user_id)
      save -> remove_save(saves, save)
    end
  end

  defp remove_save(saves, save) do
    case Timeline.delete_save(save) do
      {:ok, _} -> {:ok, Enum.filter(saves, &(&1.id != save.id))}
      {:error, _} = error -> error
    end
  end

  defp add_save(saves, clip_id, user_id) do
    case Timeline.create_save(%{clip_id: clip_id, user_id: user_id}) do
      {:ok, save} -> {:ok, [save | saves]}
      {:error, _} = error -> error
    end
  end

  def yt_url(%Video{yt_video_id: yt_video_id}) do
    "https://youtube.com/watch?v=#{yt_video_id}"
  end

  def title(%Video{title: title}) do
    HtmlEntities.decode(title)
  end

  def publish_date(%Video{publish_date: publish_date}) do
    {:ok, dt, 0} = DateTime.from_iso8601(publish_date)

    d = DateTime.add(dt, -18000) |> DateTime.to_date()

    "#{d.month}/#{d.day}/#{d.year}"
  end

  def short_link(%Clip{id: id}) do
    slug = String.slice(id, 0..5)

    "https://cclip.art/" <> slug
  end

  def short_link(_) do
    "https://cclip.art"
  end

  def page_metadata(%{assigns: %{clip: clip}} = socket) do
    socket
    |> assign(:metadata_title, clip.title)
    |> assign(:metadata_url, short_link(clip))
    |> assign(:metadata_image, clip.yt_thumbnail_url)
    |> assign(:metadata_description, Clip.description(clip))
  end

  def page_metadata(socket), do: socket
end
