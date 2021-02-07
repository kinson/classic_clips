defmodule ClassicClipsWeb.ClipLive.ClipComponent do
  use ClassicClipsWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket, temporary_assigns: [votes: []]}
  end

  @impl true
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
          <div class="icon" phx-click="inc_votes" phx-target="<%= @myself %>">
            <div class="<%= get_vote_class(@id, @votes, @user)%> arrow"></div>
          </div>
          <p class="leigh-score"><%= @clip.vote_count %></p>
          <div class="leigh-label-container"><p><%= @clip.user.username || @clip.user.email %></p></div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("inc_votes", _value, socket) do
    # IO.inspect(socket.assigns)
    case can_vote?(socket.assigns.id, socket.assigns.votes, socket.assigns.user) do
      true ->
        {:noreply, socket}

      false ->
        {:ok, vote} = ClassicClips.Timeline.inc_votes(socket.assigns.clip, socket.assigns.user)
        # IO.inspect(socket.assigns)
        # IO.inspect(vote)
        # IO.inspect(update(socket, :votes, fn votes -> [vote | votes] end))
        {:noreply, assign(socket, :votes, [vote | socket.assigns.votes])}
    end
  end

  defp get_vote_class(clip_id, votes, user) do
    case can_vote?(clip_id, votes, user) do
      true -> "leigh-score-voted"
      false -> "leigh-score-not-voted"
    end
  end

  defp has_voted_already?(clip_id, votes) do
    Enum.any?(votes, fn vote -> vote.clip_id == clip_id end)
  end

  defp can_vote?(clip_id, votes, user) do
    has_voted_already?(clip_id, votes) and not is_nil(user)
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

  defp format_time_text(seconds) when seconds < 10, do: "0#{seconds}"
  defp format_time_text(seconds), do: "#{seconds}"
end
