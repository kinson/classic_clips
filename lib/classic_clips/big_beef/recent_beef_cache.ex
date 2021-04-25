defmodule ClassicClips.BigBeef.RecentBeefCache do
  use GenServer

  @table :big_beef
  @clear_after :timer.seconds(15)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    :ets.new(@table, [
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])

    schedule_clear()
    {:ok, state}
  end

  @impl true
  def handle_info(:clear, state) do
    :ets.delete_all_objects(@table)
    schedule_clear()
    {:noreply, state}
  end

  defp schedule_clear() do
    Process.send_after(self(), :clear, @clear_after)
  end

  def get_recent_beefs(offset) do
    case :ets.lookup(@table, {:beef, offset}) do
      [] -> nil
      [{_, result} | _] -> result
    end
  end

  def apply_cache(beef_data, offset) do
    :ets.insert(@table, {{:beef, offset}, beef_data})
    beef_data
  end
end
