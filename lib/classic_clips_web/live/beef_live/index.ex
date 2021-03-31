defmodule ClassicClipsWeb.BeefLive.Index do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.BigBeef
  alias ClassicClips.BigBeef.Beef
  alias ClassicClips.BigBeef.{Player, BigBeefEvent}

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: BigBeef.subscribe_new_beef()

    active_game_count = get_active_game_count()
    big_beefs = ClassicClips.BigBeef.list_big_beef_events()

    modified_socket =
      socket
      |> assign(:beefs, BigBeef.get_recent_beefs(active_game_count))
      |> assign(:last_updated, current_datetime())
      |> assign(:active_game_count, active_game_count)
      |> assign(:big_beefs, big_beefs)
      |> assign(:page_type, "live")

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
    |> assign(:page_title, "BIG BEEF TRACKER")
    |> assign(:beef, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    beef = BigBeef.get_beef!(id)
    {:ok, _} = BigBeef.delete_beef(beef)

    {:noreply, assign(socket, :beefs, list_beefs())}
  end

  def handle_event("select-archive", _, socket) do
    {:noreply, assign(socket, :page_type, "archive")}
  end

  def handle_event("select-live", _, socket) do
    {:noreply, assign(socket, :page_type, "live")}
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

  def format_time(time) do
    six_hour_back_offset = -1 * 60 * 60 * 6

    time
    |> DateTime.add(six_hour_back_offset, :second)
    |> DateTime.to_date()
    |> Date.to_string()
  end

  def name(%Player{first_name: first_name, last_name: last_name}) do
    "#{last_name}, #{first_name}"
  end

  def count(%Beef{beef_count: count}), do: count

  def bs_link(%BigBeefEvent{box_score_url: url}) do
    case String.contains?(url, "https://") do
      true -> url
      false -> "#"
    end
  end

  def yt_link(%BigBeefEvent{yt_highlight_video_url: url}) do
    case String.contains?(url, "https://") do
      true -> url
      false -> "#"
    end
  end

  def yt_text(%BigBeefEvent{yt_highlight_video_url: url}) do
    case String.contains?(url, "https://") do
      true -> "Big Beef Highlights"
      false -> "Coming Soon..."
    end
  end

  def bs_text(%BigBeefEvent{box_score_url: url}) do
    case String.contains?(url, "https://") do
      true -> "Box Score"
      false -> "Coming Soon..."
    end
  end

  def is_active(page, name) do
    case page == name do
      true -> "show"
      false -> ""
    end
  end
end
