defmodule BigBeefWeb.BeefLive.Helpers do
  alias ClassicClips.BigBeef.Beef
  alias ClassicClips.BigBeef.{Player, BigBeefEvent}

  def is_active(page, name) do
    case page == name do
      true -> "show"
      false -> ""
    end
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

  def name(%Player{first_name: first_name, last_name: last_name}) do
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

  def yt_text(%BigBeefEvent{yt_highlight_video_url: "none"}), do: "No Beef Highlights"

  def yt_text(%BigBeefEvent{yt_highlight_video_url: "notyet"}), do: "Highlights Coming Soon..."

  def yt_text(%BigBeefEvent{yt_highlight_video_url: url}) do
    case String.contains?(url, "https://") do
      true -> "Big Beef Highlights"
      false -> "Highlights Not Available"
    end
  end

  def bs_text(%BigBeefEvent{box_score_url: url}) do
    case String.contains?(url, "https://") do
      true -> "Box Score"
      false -> "Box Score Coming Soon..."
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
