# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :classic_clips,
  ecto_repos: [ClassicClips.Repo]

# Configures the endpoint
config :classic_clips, ClassicClipsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZaWIHgxKEl5jFFtPd3SNSpFGLbCR3XLm8nYdwW5pq+QDIJ7WKrHsKrQXaqSKffGB",
  render_errors: [view: ClassicClipsWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ClassicClips.PubSub,
  live_view: [signing_salt: "ISFu52hQ"]

config :classic_clips, BigBeefWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZaWIHgxKEl5jFFtPd3SNSpFGLbCR3XLm8nYdwW5pq+QDIJ7WKrHsKrQXaqSKffGB",
  render_errors: [view: BigBeefWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: ClassicClips.PubSub,
  live_view: [signing_salt: "ISFu52hQ"]

config :sentry,
  dsn: System.get_env("SENTRY_DSN"),
  environment_name: Mix.env(),
  enable_source_code_context: true,
  root_source_code_path: File.cwd!(),
  tags: %{env: "prod"},
  included_environments: [:prod]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :classic_clips,
       :dash_pass,
       System.get_env("DASH_PASS") ||
         raise("""
         Could not find DASH_PASS environment variable.
         """)

         config :classic_clips,
         :big_beef_url,
         System.get_env("BIG_BEEF_URL") ||
           raise("""
           Could not find BIG_BEEF_URL environment variable.
           """)

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
