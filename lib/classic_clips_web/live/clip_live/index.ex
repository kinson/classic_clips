defmodule ClassicClipsWeb.ClipLive.Index do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.Timeline
  alias ClassicClips.Timeline.Clip

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :clips, list_clips())}
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
end
