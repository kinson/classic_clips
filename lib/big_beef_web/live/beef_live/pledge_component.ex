defmodule BigBeefWeb.BeefLive.PledgeComponent do
  use BigBeefWeb, :live_component

  import BigBeefWeb.BeefLive.Helpers

  def render(assigns) do
    ~H"""
    <div class={"pledge-beef saucy #{is_active(@page_type, "pledge")}"}>
      <p class="beef-card-label">
        Raising Money to End Food Insecurity
      </p>
      <div class="pledge-card">
        <div class="raised">
          <p class="amount">
            $604
          </p>
          <p class="description">
            donated as of January 20th, 2023 ❄️
          </p>
        </div>

        <p>
          For the third season, Big Beef Tracker is giving back by donating to
          <a href="https://www.feedingamerica.org/">
            Feeding America
          </a>
          , an organization trying to put an end to food insecurity across the United States.
        </p>
        <p>
          Big Beef Tracker is pledging $1 for each rebound in a big beef performance through the end of the season (including the playoffs).
        </p>

        <p class="cta">
          Want to contribute? Tweet or message
          <a href="https://twitter.com/BigBeefTracker">
            @BigBeefTracker
          </a>
          when you make a donation to Feeding America (or your local food bank) and it will be added to the total!
        </p>
      </div>
    </div>
    """
  end
end
