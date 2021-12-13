source .env
export MIX_ENV=prod

echo "Stopping application"
_build/prod/rel/classic_clips/bin/classic_clips stop

echo "Fetching latest deps"
mix deps.get --only prod

echo "Building application"
mix assets.deploy
mix release --overwrite

echo "Migrating"
mix ecto.migrate

echo "Starting application"
_build/prod/rel/classic_clips/bin/classic_clips daemon
