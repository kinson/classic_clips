defmodule ClassicClipsWeb.ClipLive.ClipComponent do
  use ClassicClipsWeb, :live_component

  alias ClassicClips.Timeline
  alias ClassicClips.Timeline.{Clip, Tag, User}
  alias ClassicClips.Classics.Video

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
          <div class="clip-edit-button <%= get_edit_class(@user, @clip) %>">
            <%= live_patch to: Routes.clip_index_path(@socket, :edit, @clip.id) do %>
              <i class="fas fa-cog"></i>
            <% end %>
          </div>
          <div class="save-button <%= get_save_class(@saves, @clip) %>" phx-click="save_clip" phx-value-clip="<%= @id %>"></div>
          <%= link @clip.title |> String.upcase(), to: @clip.yt_video_url, class: "tas-text", target: "_blank" %>
          <%= link get_publish_date(@clip.video), to: Routes.clip_index_path(@socket, :show, @clip.id) , class: "tas-date" %>
          <p class="tas-time"><%= get_duration(@clip.clip_length) %></p>
            <a href="<%= @clip.yt_video_url %>" target="_blank">
              <img class="tas-image" src="<%= @clip.yt_thumbnail_url %>" />
            </a>
        </div>
        <div class="leigh-container">
          <div class="<%= Timeline.get_vote_class(@id, @votes, @user) %> icon" phx-click="inc_votes" phx-value-clip="<%= @id %>">
            <div class="arrow"></div>
          </div>
          <p class="leigh-score"><%= @clip.vote_count %></p>
          <%= if has_tags?(@clip) do %>
            <div class="leigh-tags">
              <i class="fas fa-tags"></i>
            </div>
          <% end %>
          <div class="leigh-label-container">
            <p><%= get_username(@clip) %></p>
          </div>
          <p class="tags-text"><%= get_tags(@clip) %></p>
        </div>
    </div>
    """
  end

  def get_publish_date(nil), do: ""

  def get_publish_date(%Video{publish_date: publish_date}) do
    {:ok, dt, 0} = DateTime.from_iso8601(publish_date)

    d = DateTime.add(dt, -18000) |> DateTime.to_date()

    "#{d.month}/#{d.day}/#{d.year}"
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

  defp has_tags?(%Clip{tags: []}) do
    false
  end

  defp has_tags?(%Clip{tags: _tags}) do
    true
  end

  defp get_tags(%Clip{tags: []}) do
    ""
  end

  defp get_tags(%Clip{tags: tags}) do
    tag_count = Enum.count(tags)
    case tag_count > 4 do
      true ->
        tag_list = Enum.take(tags, 4) |> tags_string()
        "#{tag_list}, and #{tag_count - 4} more tags"


      false ->
        tags_string(tags)
    end

  end

  defp tags_string(tags) do
    Enum.reduce(tags, "", fn %Tag{name: name}, acc ->
      acc <> "#{name}, "
    end)
    |> String.replace_trailing(", ", "")
  end

  defp format_time_text(seconds) when seconds < 10, do: "0#{seconds}"
  defp format_time_text(seconds), do: "#{seconds}"

  defp get_save_class(saves, %Clip{id: id}) do
    case Enum.any?(saves, &(id == &1.clip_id)) do
      true -> "saved"
      false -> ""
    end
  end

  defp get_edit_class(%User{id: user_id}, %Clip{} = clip) do
    case user_id == clip.user.id do
      true -> ""
      false -> "hide"
    end
  end

  defp get_edit_class(_, _) do
    "hide"
  end
end
