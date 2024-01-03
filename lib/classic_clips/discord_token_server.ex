defmodule ClassicClips.DiscordTokenServer do
  require Logger

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Logger.info("Starting #{__MODULE__}")
    refresh_tokens()
    :timer.send_interval(900_000, :work)

    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    refresh_tokens()
    {:noreply, state}
  end

  def refresh_tokens do
    tokens = ClassicClips.PickEm.get_discord_tokens_near_expiration()

    Logger.info("refreshing #{Enum.count(tokens)} tokens")

    Enum.each(tokens, fn dt ->
      case ClassicClips.Discord.refresh_access_token(dt)
           |> ClassicClips.Discord.handle_refresh_response() do
        {:ok, new_tokens} ->
          ClassicClips.PickEm.upsert_discord_tokens(dt, new_tokens)

        {:error, error} ->
          Logger.error("failed to refresh token for Discord server")

          Sentry.Event.create_event(
            message: "failed to refresh Discord server token: #{inspect(error)}"
          )
          |> Sentry.send_event()
      end
    end)
  end
end
