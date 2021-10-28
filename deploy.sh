source .env
export MIX_ENV=prod

mix assets.deploy
mix compile
mix ecto.migrate

kill -9 $(lsof -t -i:4000)
kill -9 $(lsof -t -i:4001)

elixir --erl "-detached" -S mix phx.server
