defmodule ClassicClipsWeb.ClipLive.Show do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.Timeline

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:clip, Timeline.get_clip!(id))}
  end

  defp page_title(:show), do: "Show Clip"
  defp page_title(:edit), do: "Edit Clip"
end
