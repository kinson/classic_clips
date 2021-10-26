defmodule BigBeefWeb.BeefLive.PreviousBeefComponent do
  use BigBeefWeb, :live_component

  import BigBeefWeb.BeefLive.Helpers

  def render(assigns) do
    ~H"""
    <div class={"previous-beef saucy #{is_active(@page_type, "archive")}"}>
      <p class="beef-card-label">Previous Big Beefs</p>
      <div class="results">
        <div class="big-beef-list">
          <%= for beef <- @big_beefs do %>
            <div class="big-beef">
              <p class="date">[<%= format_time(beef.beef.date_time) %>]</p>
              <p class="name"><%= name(beef.beef.player) %></p>
              <p class="count"><%= count(beef.beef) %> 🥩</p>
              <a class="highlights" href={yt_link(beef)} target="_blank"><%= yt_text(beef) %></a>
              <a class="box-score" href={bs_link(beef)} target="_blank"><%= bs_text(beef) %></a>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end
end
