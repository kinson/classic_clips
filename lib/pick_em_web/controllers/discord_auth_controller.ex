defmodule PickEmWeb.DiscordAuthController do
  use PickEmWeb, :controller
  use NewRelic.Tracer

  require Logger

  alias ClassicClips.{PickEm, Discord}

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  @trace :index
  def index(conn, %{"code" => code}) do
    {:ok, access_token_response} =
      Discord.get_access_token(code) |> Discord.handle_token_response()

    case PickEm.get_discord_token_for_server(access_token_response["webhook_server_id"]) do
      nil -> PickEm.create_discord_token(access_token_response)
      dt -> PickEm.update_discord_token(dt, access_token_response)
    end

    conn
    |> put_flash(:info, "Discord application added!")
    |> redirect(to: "/")
  end

  def index(conn, _params) do
    Sentry.Event.create_event(message: "Discord controller without code")
    |> Sentry.send_event()

    put_flash(conn, :error, "Failed to login with Discord")
    |> redirect(to: "/")
  end

  @trace :logout
  def logout(conn, _) do
    conn
    |> clear_session()
    |> redirect(to: Routes.pick_em_index_path(conn, :index))
  end
end
