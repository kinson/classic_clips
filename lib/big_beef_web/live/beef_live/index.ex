defmodule BigBeefWeb.BeefLive.Index do
  use BigBeefWeb, :live_view
  use NewRelic.Tracer

  alias ClassicClips.BigBeef
  alias ClassicClips.BigBeef.Beef
  alias ClassicClips.BigBeef.{Player, BigBeefEvent}

  @impl true
  @trace :mount
  def mount(_params, _session, socket) do
    if connected?(socket), do: BigBeef.subscribe_new_beef()

    active_game_count = get_active_game_count()
    big_beefs = ClassicClips.BigBeef.get_big_beefs_by_season()
    latest = ClassicClips.BigBeef.get_latest_big_beef()
    single_game_leaders = ClassicClips.BigBeef.get_single_game_leaders()
    total_big_beef_leaders = ClassicClips.BigBeef.get_big_beef_count_leaders()
    season_single_game_leaders = ClassicClips.BigBeef.get_season_single_game_leaders()
    season_total_big_beef_leaders = ClassicClips.BigBeef.get_season_big_beef_count_leaders()
    beefs = BigBeef.get_recent_beefs_cached(active_game_count)

    IO.inspect(:erlang.external_size(beefs), label: "beefs size")
    IO.inspect(:erlang.external_size(active_game_count), label: "active_game_count size")
    IO.inspect(:erlang.external_size(big_beefs), label: "big_beefs size")
    IO.inspect(:erlang.external_size(latest), label: "latest size")
    IO.inspect(:erlang.external_size(single_game_leaders), label: "single_game_leaders size")

    IO.inspect(:erlang.external_size(total_big_beef_leaders), label: "total_big_beef_leaders size")

    IO.inspect(:erlang.external_size(season_single_game_leaders),
      label: "season_single_game_leaders size"
    )

    IO.inspect(:erlang.external_size(season_total_big_beef_leaders),
      label: "season_total_big_beef_leaders size"
    )

    modified_socket =
      socket
      |> assign(:beefs, beefs)
      |> assign(:last_updated, current_datetime())
      |> assign(:active_game_count, active_game_count)
      |> assign(:big_beefs, big_beefs)
      |> assign(:page_type, "live")
      |> assign(:latest, latest)
      |> assign(:total_leaders, total_big_beef_leaders)
      |> assign(:season_total_leaders, season_total_big_beef_leaders)
      |> assign(:single_game_leaders, single_game_leaders)
      |> assign(:season_single_game_leaders, season_single_game_leaders)

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

  def handle_event("select-stats", _, socket) do
    {:noreply, assign(socket, :page_type, "stats")}
  end

  def handle_event("select-pledge", _, socket) do
    {:noreply, assign(socket, :page_type, "pledge")}
  end

  @trace :list_beefs
  defp list_beefs do
    BigBeef.list_beefs()
  end

  defp current_datetime do
    DateTime.utc_now() |> DateTime.to_iso8601()
  end

  @trace :get_active_game_count
  defp get_active_game_count() do
    ClassicClips.BeefServer.get_active_game_count()
  end

  def format_time(time) do
    six_hour_back_offset = -1 * 60 * 60 * 6

    d =
      time
      |> DateTime.add(six_hour_back_offset, :second)
      |> DateTime.to_date()

    month = d.month
    day = d.day
    year = d.year

    month =
      case month do
        1 -> "January"
        2 -> "February"
        3 -> "March"
        4 -> "April"
        5 -> "May"
        6 -> "June"
        7 -> "July"
        8 -> "August"
        9 -> "September"
        10 -> "October"
        11 -> "November"
        12 -> "December"
      end

    day_th =
      case day do
        n when n in [1, 21, 31] -> "st"
        n when n in [2, 22] -> "nd"
        n when n in [3, 23] -> "rd"
        _ -> "th"
      end

    "#{month} #{day}#{day_th}, #{year}"
  end

  def name(%{first_name: first_name, last_name: last_name}) do
    "#{first_name} #{last_name}"
  end

  def player_headshot_link(%Player{ext_person_id: ext_person_id}) do
    "https://cdn.nba.com/headshots/nba/latest/260x190/#{ext_person_id}.png"
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
      false -> "Highlights Coming Soon..."
    end
  end

  def bs_text(%BigBeefEvent{box_score_url: url}) do
    case String.contains?(url, "https://") do
      true -> "Box Score"
      false -> "Box Score Coming Soon..."
    end
  end

  def is_active(page, name) do
    case page == name do
      true -> "show"
      false -> ""
    end
  end

  def with_rank("total", leaders) do
    {leaders, _} =
      Enum.map_reduce(leaders, {0, 0}, fn {_, first_name, last_name, beef_count},
                                          {rank, current} ->
        new_rank =
          case beef_count == current do
            true -> rank
            false -> rank + 1
          end

        {{new_rank, first_name, last_name, beef_count}, {new_rank, beef_count}}
      end)

    leaders
  end

  def with_rank("single", leaders) do
    {leaders, _} =
      Enum.map_reduce(leaders, {0, 0}, fn %Beef{
                                            player: %Player{
                                              first_name: first_name,
                                              last_name: last_name
                                            },
                                            beef_count: beef_count
                                          },
                                          {rank, current} ->
        new_rank =
          case beef_count == current do
            true -> rank
            false -> rank + 1
          end

        {{new_rank, first_name, last_name, beef_count}, {new_rank, beef_count}}
      end)

    leaders
  end
end
