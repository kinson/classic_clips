defmodule ClassicClips.MatchupPublishServer do
  use GenServer

  require Logger

  alias ClassicClips.PickEm

  @interval :timer.seconds(30)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    Logger.notice("Starting #{__MODULE__}")
    {:ok, %{}, @interval}
  end

  @impl true
  def handle_info(:timeout, state) do
    # check for unpublished matchups that have passed publish at threshold
    case PickEm.get_matchup_ready_for_publishing() do
      nil ->
        Logger.info("No matchups ready to publish")
        {:noreply, state, @interval}

      matchup ->
        Logger.notice("Publishing matchup starting at: #{matchup.tip_datetime}")
        PickEm.publish_matchup(matchup)
        {:noreply, state, @interval}
    end
  end
end
