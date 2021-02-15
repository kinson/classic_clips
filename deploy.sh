source .env

export MIX_ENV=prod

npm run deploy --prefix ./assets/

mix phx.digest

mix compile

mix ecto.migrate

PORT=4000 elixir --erl "-detached" -S mix phx.server