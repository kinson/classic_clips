defmodule ClassicClips.MixProject do
  use Mix.Project

  def project do
    [
      app: :classic_clips,
      version: "1.2.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ClassicClips.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:fiat, "~> 1.0.0"},
      {:logflare_logger_backend, "~> 0.11.0"},
      {:elixir_auth_google, "~> 1.6.0"},
      {:sentry, "8.0.0"},
      {:html_entities, "~> 0.5"},
      {:phoenix, "~> 1.6"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.7"},
      {:ecto_psql_extras, "~> 0.7"},
      {:logger_file_backend, "~> 0.0.11"},
      {:postgrex, "~> 0.15"},
      {:phoenix_live_view, "~> 0.18"},
      {:floki, ">= 0.27.0", only: :test},
      {:new_relic_agent, "~> 1.27"},
      {:phoenix_html, "~> 3.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:timex, "~> 3.7"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.3"},
      {:plug_cowboy, "~> 2.5"},
      {:swoosh, "~> 1.6"},
      {:esbuild, "~> 0.3", runtime: Mix.env() == :dev},
      {:dart_sass, "~> 0.3", runtime: Mix.env() == :dev}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "assets.deploy": [
        "cmd --cd assets npm run deploy",
        "esbuild default --minify",
        "sass default",
        "phx.digest"
      ],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
