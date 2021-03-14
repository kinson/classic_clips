defmodule ClassicClipsWeb.ClassicsView do
  use ClassicClipsWeb, :view

  alias ClassicClips.Classics.Video

  # def render(conn)

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

  def little_list(classics) do
    classics
    |> Enum.with_index()
    |> Enum.slice(5, 6)
  end

  def title(%Video{title: title}) do
    HtmlEntities.decode(title)
  end

  def publish_date(%Video{publish_date: publish_date}) do
    {:ok, dt, 0} = DateTime.from_iso8601(publish_date)

    d = DateTime.add(dt, -18000) |>  DateTime.to_date()

    "#{d.month}/#{d.day}/#{d.year}"
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
