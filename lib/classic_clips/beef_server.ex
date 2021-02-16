defmodule ClassicClips.BeefServer do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    :timer.send_interval(1200_000, :work)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    fetch_beef_data(state)
    {:noreply, state}
  end

  defp fetch_beef_data(_state) do
    # Here you would do whatever it is you need to do.
    # You don't have to use the state, this is only to show you can.
    ClassicClips.BigBeef.get_games()
  end
end
