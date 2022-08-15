defmodule ClassicClips.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  require Logger

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ClassicClips.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: ClassicClips.PubSub},
      # Start the Endpoint (http/https)
      # Start a worker by calling: ClassicClips.Worker.start_link(arg)
      # {ClassicClips.Worker, arg}
      # Start Fiat cache
      Fiat.CacheServer,
      # Start Task Supervisor
      {Task.Supervisor, name: ClassicClips.TaskSupervisor}
    ]

    services_to_start = Application.fetch_env!(:classic_clips, :service)

    Logger.warn("Starting application service: #{services_to_start}")

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ClassicClips.Supervisor]
    Supervisor.start_link(children ++ get_children(services_to_start), opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ClassicClipsWeb.Endpoint.config_change(changed, removed)
    BigBeefWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp get_children(:all) do
    classic_clips_children() ++ big_beef_children() ++ pick_em_children()
  end

  defp get_children(:classic_clips), do: classic_clips_children()
  defp get_children(:big_beef), do: big_beef_children()
  defp get_children(:pick_em), do: pick_em_children()

  defp classic_clips_children() do
    [ClassicClipsWeb.Endpoint, ClassicClipsWeb.Telemetry, ClassicClips.ClassicsServer]
  end

  defp big_beef_children() do
    [
      BigBeefWeb.Endpoint,
      BigBeefWeb.Telemetry,
      ClassicClips.BeefServer,
      ClassicClips.BigBeef.RecentBeefCache,
      ClassicClips.BigBeef.BigBeefWaiterServer,
      ClassicClips.BigBeef.BeefRedactionServer
    ]
  end

  defp pick_em_children() do
    [
      PickEmWeb.Endpoint,
      ClassicClips.MatchupServer
    ]
  end
end
