source .env
export MIX_ENV=prod

mix assets.deploy
mix release
mix ecto.migrate

_build/prod/rel/classic_clips/bin/classic_clips stop

_build/prod/rel/classic_clips/bin/classic_clips daemon
