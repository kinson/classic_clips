defmodule ClassicClips.Repo do
  use Ecto.Repo,
    otp_app: :classic_clips,
    adapter: Ecto.Adapters.Postgres
end
