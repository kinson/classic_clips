defmodule ClassicClips.BigBeef.BigBeefWaiterServer do
  use GenServer

  require Logger

  @polling_interval :timer.minutes(5)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{beefs: %{}}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    new_state = query_big_beef(state)

    schedule_query()
    {:ok, new_state}
  end

  @impl true
  def handle_info(:query, state) do
    new_state = query_big_beef(state)

    schedule_query()
    {:noreply, new_state}
  end

  defp schedule_query() do
    Process.send_after(self(), :query, @polling_interval)
  end

  defp query_big_beef(state) do
    case check_for_big_beefs(state) do
      {nil, updated_state} ->
        updated_state

      {beef, updated_state} ->
        ClassicClips.BigBeef.create_big_beef_event(%{beef_id: beef.id})
        log_new_big_beef()
        updated_state
    end
  end

  defp check_for_big_beefs(state) do
    case ClassicClips.BigBeef.get_unclaimed_big_beefs() do
      [] ->
        {nil, state}

      [big_beef | _] ->
        IO.puts("found unclaimed big beef!")
        check_big_beef_marinade(state, big_beef)
    end
  end

  defp check_big_beef_marinade(%{beefs: beefs}, beef) do
    case Map.get(beefs, beef.id) do
      nil -> {nil, %{beefs: Map.put_new(beefs, beef.id, 1)}}
      1 -> {nil, %{beefs: Map.put(beefs, beef.id, 2)}}
      2 -> {beef, %{beefs: Map.delete(beefs, beef.id)}}
    end
  end

  defp log_new_big_beef() do
    message = "New big beef event created!"

    Logger.notice(message)

    Sentry.Event.create_event(message: message)
    |> Sentry.send_event()
  end
end
