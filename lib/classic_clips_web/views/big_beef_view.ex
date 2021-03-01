defmodule ClassicClipsWeb.BigBeefView do
  use ClassicClipsWeb, :view

  alias ClassicClips.BigBeef.{Player, Beef, BigBeefEvent}

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
end
