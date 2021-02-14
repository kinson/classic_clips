defmodule ClassicClipsWeb.BeefLive.Index do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.BigBeef
  alias ClassicClips.BigBeef.Beef

  @impl true
  def mount(_params, _session, socket) do

    modified_socket =
      socket
      |> assign(:beefs, list_beefs())
      |> assign(:user, nil)
      |> assign(:gooogle_auth_url, "")
    {:ok, modified_socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Beef")
    |> assign(:beef, BigBeef.get_beef!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Beef")
    |> assign(:beef, %Beef{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Beefs")
    |> assign(:beef, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    beef = BigBeef.get_beef!(id)
    {:ok, _} = BigBeef.delete_beef(beef)

    {:noreply, assign(socket, :beefs, list_beefs())}
  end

  defp list_beefs do
    BigBeef.list_beefs()
  end
end
