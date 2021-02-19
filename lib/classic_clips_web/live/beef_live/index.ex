defmodule ClassicClipsWeb.BeefLive.Index do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.BigBeef
  alias ClassicClips.BigBeef.Beef

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: BigBeef.subscribe_new_beef()

    modified_socket =
      socket
      |> assign(:beefs, BigBeef.get_recent_beefs())
      |> assign(:user, nil)
      |> assign(:is_beef_page, true)
      |> assign(:gooogle_auth_url, "")
      |> assign(:last_updated, current_datetime())
      |> assign(:active_game_count, get_active_game_count())

    {:ok, modified_socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_info({:new_beef, beefs}, socket) do
    modified_socket =
      socket
      |> assign(:last_updated, current_datetime())
      |> assign(:active_game_count, get_active_game_count())
      |> assign(:beefs, beefs)

    {:noreply, modified_socket}
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

  defp current_datetime do
    DateTime.utc_now() |> DateTime.to_iso8601()
  end

  defp get_active_game_count() do
    ClassicClips.BeefServer.get_active_game_count()
  end
end
