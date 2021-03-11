defmodule ClassicClips.ClassicsServer do
  use GenServer

  alias ClassicClips.Classics

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: Classics)
  end

  @impl true
  def init(state) do
    :timer.send_interval(500_000, :work)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    fetch_videos()
    {:noreply, state}
  end

  @impl true
  def handle_call(:get_videos, _, state) do
    {:reply, true, state}
  end

  def fetch_videos() do
    Classics.fetch_recent_videos()
  end
end
