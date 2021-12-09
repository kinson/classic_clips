source .env
export MIX_ENV=prod

mix deps.get --only prod

mix assets.deploy
mix release --overwrite

echo "Stopping application"
_build/prod/rel/classic_clips/bin/classic_clips stop

sleep 1

echo "Migrating"
mix ecto.migrate

sleep 1

echo "Starting application"
_build/prod/rel/classic_clips/bin/classic_clips daemon
