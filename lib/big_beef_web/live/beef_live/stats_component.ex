defmodule BigBeefWeb.BeefLive.StatsComponent do
  use BigBeefWeb, :live_component

  import BigBeefWeb.BeefLive.Helpers

  def render(assigns) do
    ~H"""
    <div class={"stats-beef saucy #{is_active(@page_type, "stats")}"}>
      <div class="latest">
        <p class="beef-card-label">
          LATEST BIG BEEF [# <%= get_season_beef_count(@big_beefs) %> ]
        </p>
        <div class="card">
          <img id="player-pic" src={player_headshot_link(@latest.beef.player)}>
          <div class="group info">
            <p class="date">
              <%= format_time(@latest.beef.date_time) %>
            </p>
            <p class="name">
              <%= name(@latest.beef.player) %>
            </p>
          </div>
          <div class="group links">
            <a href={bs_link(@latest)} target="_blank">
              <%= bs_text(@latest) %>
            </a>
            <a href={yt_link(@latest)} target="_blank">
              <%= yt_text(@latest) %>
            </a>
          </div>
          <div class="total-container">
            <p>
              <%= @latest.beef.beef_count %>
              <span>🥩</span>
            </p>
          </div>
        </div>
      </div>
      <div class="season-all-time">
        <p class="beef-card-label">
          SEASON BIG BEEF GAME LEADERS [TOP 5]
        </p>
        <div class="card">
          <%= for {rank, first_name, last_name, beef_count} <- with_rank("total", @season_total_leaders) do %>
            <div class="stat-row">
              <p class="name">
                <%= "#{rank}. #{first_name} #{last_name}" %>
              </p>
              <p class="number">
                <%= beef_count %>
              </p>
            </div>
          <% end %>
        </div>
      </div>
      <div class="season-single-game">
        <p class="beef-card-label">
          SEASON SINGLE-GAME BEEF LEADERS [TOP 5]
        </p>
        <div class="card">
          <%= for {rank, first_name, last_name, beef_count} <- with_rank("single", @season_single_game_leaders) do %>
            <div class="stat-row">
              <p class="name">
                <%= "#{rank}. #{first_name} #{last_name}" %>
              </p>
              <p class="number">
                <%= beef_count %>
              </p>
            </div>
          <% end %>
        </div>
      </div>
      <div class="all-time">
        <p class="beef-card-label">
          ALL-TIME BIG BEEF GAME LEADERS [TOP 5]
        </p>
        <div class="card">
          <%= for {rank, first_name, last_name, beef_count} <- with_rank("total", @total_leaders) do %>
            <div class="stat-row">
              <p class="name">
                <%= "#{rank}. #{first_name} #{last_name}" %>
              </p>
              <p class="number">
                <%= beef_count %>
              </p>
            </div>
          <% end %>
        </div>
      </div>
      <div class="single-game">
        <p class="beef-card-label">
          ALL-TIME SINGLE-GAME LEADERS [TOP 5]
        </p>
        <div class="card">
          <%= for {rank, first_name, last_name, beef_count} <- with_rank("single", @single_game_leaders) do %>
            <div class="stat-row">
              <p class="name">
                <%= "#{rank}. #{first_name} #{last_name}" %>
              </p>
              <p class="number">
                <%= beef_count %>
              </p>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  def get_season_beef_count([{_, big_beefs} | _]) do
    Enum.count(big_beefs)
  end
end
