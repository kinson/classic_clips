defmodule ClassicClipsWeb.ClassicLive.Index do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.Classics.Video
  alias ClassicClips.Classics

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = get_or_create_user(session)

    pagination = default_pagination()
    classics = search_classics(pagination)

    modifed_socket =
      socket
      |> assign(:user, user)
      |> assign(:google_auth_url, generate_oauth_url())
      |> assign(:thumbs_up_total, get_user_thumbs_up(user))
      |> assign(:pagination, pagination)
      |> assign(:classics, classics)
      |> assign(:search_term, "")
      |> assign(:filter, "")
      |> assign(:types, get_classic_types())
      |> assign(:page_title, "Classics")

    {:ok, modifed_socket}
  end

  @impl true
  def handle_event(
        "more_classics",
        _,
        %{assigns: %{search_term: search_term, filter: filter}} = socket
      ) do
    pagination = incr_pagination(socket.assigns.pagination)
    new_classics = search_classics(search_term, filter, pagination)

    all_classics = Enum.concat(socket.assigns.classics, new_classics)

    modified_socket =
      assign(socket, :classics, all_classics)
      |> assign(:pagination, pagination)

    {:noreply, modified_socket}
  end

  def handle_event(
        "change_search",
        %{"search" => %{"term" => search_term}},
        %{assigns: %{filter: filter}} = socket
      ) do
    pagination = default_pagination()
    classics = search_classics(search_term, filter, pagination)

    modified_socket =
      assign(socket, :classics, classics)
      |> assign(:pagination, pagination)
      |> assign(:search_term, search_term)

    {:noreply, modified_socket}
  end

  def handle_event(
        "change_filter",
        %{"filter" => %{"type" => type}},
        %{assigns: %{search_term: search_term}} = socket
      ) do
    pagination = default_pagination()
    classics = search_classics(search_term, type, pagination)

    modified_socket =
      assign(socket, :classics, classics)
      |> assign(:pagination, pagination)
      |> assign(:filter, type)

    {:noreply, modified_socket}
  end

  defp search_classics(pagination) do
    {:ok, classics} = Classics.search_classics("", "", pagination)
    classics
  end

  defp search_classics(search_term, filter, pagination) do
    {:ok, classics} = Classics.search_classics(search_term, filter, pagination)
    classics
  end

  defp get_classic_types() do
    [ALL: ""] ++ Enum.into(Classics.get_classic_types(), [], fn x -> {x, x} end)
  end

  defp default_pagination() do
    %{limit: 11, offset: 0}
  end

  defp incr_pagination(%{limit: _limit, offset: 0}) do
    %{limit: 12, offset: 11}
  end

  defp incr_pagination(%{limit: _limit, offset: offset}) do
    %{limit: 12, offset: offset + 12}
  end

  def image_url(%Video{thumbnails: %{"medium" => %{"url" => url}}}) do
    url
  end

  def classic_class(index) do
    "item#{index + 1}"
  end

  def big_list(classics) do
    classics
    |> Enum.with_index()
    |> Enum.slice(0, 5)
  end

  def medium_list(classics) do
    classics
    |> Enum.with_index()
    |> Enum.slice(5, 6)
  end

  def little_list(classics) do
    classics
    |> Enum.with_index()
    |> Enum.slice(11, 100)
  end

  def title(%Video{title: title}) do
    HtmlEntities.decode(title)
  end

  def publish_date(%Video{publish_date: publish_date}) do
    {:ok, dt, 0} = DateTime.from_iso8601(publish_date)

    d = DateTime.add(dt, -18000) |> DateTime.to_date()

    day_of_week = Date.day_of_week(d) |> weekday()

    "#{day_of_week} #{d.month}/#{d.day}/#{d.year}"
  end

  defp weekday(1), do: "Monday"
  defp weekday(2), do: "Tuesday"
  defp weekday(3), do: "Wednesday"
  defp weekday(4), do: "Thursday"
  defp weekday(5), do: "Friday"
  defp weekday(6), do: "Saturday"
  defp weekday(7), do: "Sunday"

  def has_clips?(%Video{clips: []}), do: false
  def has_clips?(%Video{clips: _}), do: true

  def count_clips(%Video{clips: clips}) do
    case Enum.count(clips) do
      1 -> "1 CLIP"
      n -> "#{n} CLIPS"
    end
  end

  def type(%Video{type: nil}) do
    "CLASSIC"
  end

  def type(%Video{type: type}) do
    type
  end

  def yt_url(%Video{yt_video_id: yt_video_id}) do
    "https://youtube.com/watch?v=#{yt_video_id}"
  end
end
