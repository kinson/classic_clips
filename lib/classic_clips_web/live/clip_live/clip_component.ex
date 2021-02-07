defmodule ClassicClipsWeb.ClipLive.ClipComponent do
  use ClassicClipsWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="clip-box">
      <div class="clip-container">
        <div class="tas-container">
          <%= link @clip.title |> String.upcase(), to: @clip.yt_thumbnail_url, class: "tas-text", target: "_blank" %>
          <p class="tas-time"><%= get_duration(@clip.clip_length) %></p>
          <img class="tas-image" src="<%= @clip.yt_thumbnail_url %>" />
        </div>
        <div class="leigh-container">
          <div class="icon">
            <div class="arrow"></div>
          </div>
          <p class="leigh-score">111</p>
          <div class="leigh-label-container"><p><%= @clip.user.username || @clip.user.email %></p></div>
        </div>
      </div>
    </div>
    """
  end

  defp get_duration(seconds) when seconds < 60, do: ":#{format_time_text(seconds)}"

  defp get_duration(seconds) when seconds < 3600 do
    minutes =
      (seconds / 60)
      |> floor()
      |> format_time_text()

    seconds =
      rem(seconds, 60)
      |> format_time_text()

    "#{minutes}:#{seconds}"
  end

  defp format_time_text(seconds) when seconds < 10, do: "0#{seconds}"
  defp format_time_text(seconds), do: "#{seconds}"
end
