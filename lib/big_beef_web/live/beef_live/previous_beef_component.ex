defmodule BigBeefWeb.BeefLive.PreviousBeefComponent do
  use BigBeefWeb, :live_component

  import BigBeefWeb.BeefLive.Helpers

  def render(assigns) do
    ~H"""
    <div class={"previous-beef saucy #{is_active(@page_type, "archive")}"}>
      <p class="beef-card-label">
        Previous Big Beefs
      </p>
      <div class="results">
        <%= for {season_start, big_beefs} <- @big_beefs do %>
          <p class="w-max bg-beef-red px-4 pt-1 rounded-md text-white text-lg opacity-75 mt-4 mb-6">
            <%= season_start %> - <%= season_start + 1 %> SEASON
          </p>
          <div class="big-beef-list">
            <%= for beef <- big_beefs do %>
              <div class="big-beef">
                <p class="date">
                  [ <%= format_time(beef.beef.date_time) %> ]
                </p>
                <p class="name">
                  <%= name(beef.beef.player) %>
                </p>
                <p class="count">
                  <%= count(beef.beef) %> 🥩
                </p>
                <a class="highlights" href={yt_link(beef)} target="_blank">
                  <%= yt_text(beef) %>
                </a>
                <a class="box-score" href={bs_link(beef)} target="_blank">
                  <%= bs_text(beef) %>
                </a>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
