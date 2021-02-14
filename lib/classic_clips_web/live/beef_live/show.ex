defmodule ClassicClipsWeb.BeefLive.Show do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.BigBeef

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:beef, BigBeef.get_beef!(id))}
  end

  defp page_title(:show), do: "Show Beef"
  defp page_title(:edit), do: "Edit Beef"
end
