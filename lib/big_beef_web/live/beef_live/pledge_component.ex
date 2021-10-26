defmodule BigBeefWeb.BeefLive.PledgeComponent do
  use BigBeefWeb, :live_component

  import BigBeefWeb.BeefLive.Helpers

  def render(assigns) do
    ~H"""
    <div class={"pledge-beef saucy #{is_active(@page_type, "pledge")}"}>
      <p class="beef-card-label">Raising Money to End Food Insecurity Again</p>
      <div class="pledge-card">
        <p>Big Beef Tracker is giving back by donating to <a href="https://www.feedingamerica.org/">Feeding America</a>, an organization trying to put an end to food insecurity across the United States.</p>
        <p>Starting on April 10th, Big Beef Tracker is pledging $1 for each rebound in a big beef performance through the end of the season (including the playoffs).</p>
        <p>Starting on June 17th, the donations will be split between Feeding America and the Muscular Dystrophy Association.</p>

        <div class="raised">
          <p class="amount">$755</p>
          <p class="description">donated as of June 27th, 2021</p>
        </div>

        <div class="playoff-bonus">
          <p class="top">2021 Playoff Bonus</p>

          <p> First Round: <span>$2</span> per rebound </p>
          <p> Second Round: <span>$3</span> per rebound </p>
          <p> Conference Finals: <span>$4</span> per rebound </p>
          <p> Finals: <span>$5</span> per rebound </p>
        </div>

        <p class="thanks-header">Thanks to fellow big beef lovers for donating:</p>
        <ul>
          <li><a href="https://twitter.com/tonguelesstibbs" target="_blank">@tonguelesstibbs</a></li>
        </ul>
        <p class="cta">Want to contribute? Tweet or message <a href="https://twitter.com/BigBeefTracker">@BigBeefTracker</a> when you make a donation to Feeding America (or your local food bank) and it will be added to the total!</p>
      </div>
      </div>
    """
  end
end
