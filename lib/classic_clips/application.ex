defmodule ClassicClips.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ClassicClips.Repo,
      # Start the Telemetry supervisor
      ClassicClipsWeb.Telemetry,
      BigBeefWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ClassicClips.PubSub},
      # Start the Endpoint (http/https)
      ClassicClipsWeb.Endpoint,
      BigBeefWeb.Endpoint,
      PickEmWeb.Endpoint,
      # Start a worker by calling: ClassicClips.Worker.start_link(arg)
      # {ClassicClips.Worker, arg}
      ClassicClips.BeefServer,
      ClassicClips.ClassicsServer,
      ClassicClips.BigBeef.RecentBeefCache,
      ClassicClips.BigBeef.BigBeefWaiterServer,
      ClassicClips.MatchupServer,
      # Start Fiat cache
      Fiat.CacheServer
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ClassicClips.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ClassicClipsWeb.Endpoint.config_change(changed, removed)
    BigBeefWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
