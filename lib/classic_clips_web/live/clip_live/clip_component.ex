defmodule ClassicClipsWeb.ClipLive.ClipComponent do
  use ClassicClipsWeb, :live_component

  def render(assigns) do
    ~L"""
    <div class="clip-box">
      <div class="clip-container">
        <div class="tas-container">
          <%= link @clip.title |> String.upcase(), to: @clip.video_ext_id, class: "tas-text", target: "_blank" %>
          <p class="tas-time"><%= @clip.clip_length %></p>
          <img class="tas-image" src="https://img.youtube.com/vi/3tOpXbKyuQU/mqdefault.jpg" />
        </div>
        <div class="leigh-container">
          <div class="icon">
            <div class="arrow"></div>
          </div>
          <p class="leigh-score">111</p>
          <div class="leigh-label-container"><p>@nodoubtaboutit</p></div>
        </div>
      </div>
    </div>
    """
  end
end
