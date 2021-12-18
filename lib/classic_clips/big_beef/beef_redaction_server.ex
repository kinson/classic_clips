defmodule ClassicClips.BigBeef.BeefRedactionServer do
  use GenServer

  require Logger

  @polling_interval :timer.minutes(30)

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Logger.notice("Starting #{__MODULE__}")

    {:ok, state, :timer.seconds(10)}
  end

  @impl true
  def handle_info(:timeout, state) do
    redact_bad_beef()

    {:noreply, state, @polling_interval}
  end

  defp redact_bad_beef do
    ClassicClips.BigBeef.check_for_bad_beefs()
  end
end
