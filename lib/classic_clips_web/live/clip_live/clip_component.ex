defmodule ClassicClipsWeb.ClipLive.ClipComponent do
  use ClassicClipsWeb, :live_component

  alias ClassicClips.Timeline
  alias ClassicClips.Timeline.Clip

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="clip-box">
      <div class="clip-container">
        <div class="tas-container">
          <div class="save-button <%= get_save_class(@saves, @clip) %>" phx-click="save_clip" phx-value-clip="<%= @id %>"></div>
          <%= link @clip.title |> String.upcase(), to: @clip.yt_video_url, class: "tas-text", target: "_blank" %>
          <p class="tas-time"><%= get_duration(@clip.clip_length) %></p>
          <img class="tas-image" src="<%= @clip.yt_thumbnail_url %>" />
        </div>
        <div class="leigh-container">
          <div class="<%= Timeline.get_vote_class(@id, @votes, @user) %> icon" phx-click="inc_votes" phx-value-clip="<%= @id %>">
            <div class="arrow"></div>
          </div>
          <p class="leigh-score"><%= @clip.vote_count %></p>
          <div class="leigh-label-container"><p><%= get_username(@clip) %></p></div>
        </div>
      </div>
    </div>
    """
  end

  defp get_duration(nil), do: ""

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

  defp get_username(clip) do
    username = clip.user.username || clip.user.email
    max_length = 16

    case String.length(username) > max_length do
      true ->
        "#{String.slice(username, 0, max_length) |> String.trim_trailing()}..."

      false ->
        username
    end
  end

  defp format_time_text(seconds) when seconds < 10, do: "0#{seconds}"
  defp format_time_text(seconds), do: "#{seconds}"

  defp get_save_class(saves, %Clip{id: id}) do
    case Enum.any?(saves, &(id == &1.clip_id)) do
      true -> "saved"
      false -> ""
    end
  end
end
