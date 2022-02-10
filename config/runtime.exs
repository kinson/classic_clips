# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

if config_env() == :prod do
  database_url =
    System.get_env("DATABASE_URL") ||
      raise """
      environment variable DATABASE_URL is missing.
      For example: ecto://USER:PASS@HOST/DATABASE
      """

  config :classic_clips, ClassicClips.Mailer,
    adapter: Swoosh.Adapters.Sendgrid,
    api_key: System.fetch_env!("SENDGRID_API_KEY")

  config :classic_clips, ClassicClips.Repo,
    ssl: true,
    url: database_url,
    pool_size: 8,
    queue_target: 500,
    queue_interval: 5000

  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  config :classic_clips, ClassicClipsWeb.Endpoint,
    http: [
      port: String.to_integer(System.get_env("PORT") || "4000"),
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base

  config :classic_clips, BigBeefWeb.Endpoint,
    http: [
      port: String.to_integer(System.get_env("PORT") || "4001"),
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base

  config :classic_clips, PickEmWeb.Endpoint,
    http: [
      port: String.to_integer(System.get_env("PORT") || "4002"),
      transport_options: [socket_opts: [:inet6]]
    ],
    secret_key_base: secret_key_base

  config :logger, :logflare_logger_backend,
    source_id: System.fetch_env!("LOGFLARE_SOURCE_ID"),
    api_key: System.fetch_env!("LOGFLARE_API_KEY")

  config :new_relic_agent,
    app_name: "classic-clips",
    license_key: System.fetch_env!("NEW_RELIC_LICENSE_KEY")
end

config :classic_clips, ClassicClipsWeb.Endpoint, server: true
config :classic_clips, BigBeefWeb.Endpoint, server: true
config :classic_clips, PickEmWeb.Endpoint, server: true
