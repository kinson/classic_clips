defmodule PickEmWeb.GoogleAuthController do
  use PickEmWeb, :controller
  use NewRelic.Tracer

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  @trace :index
  def index(conn, %{"code" => code}) do
    {:ok, token} = ElixirAuthGoogle.get_token(code, conn)
    {:ok, profile} = ElixirAuthGoogle.get_user_profile(token.access_token)

    put_session(conn, :profile, profile)
    |> redirect(to: "/")
  end

  def index(conn, _params) do
    Sentry.Event.create_event(message: "Auth controller without code")
    |> Sentry.send_event()

    put_flash(conn, :error, "Failed to login with Google")
    |> redirect(to: "/")
  end

  @trace :logout
  def logout(conn, _) do
    conn
    |> clear_session()
    |> redirect(to: Routes.pick_em_index_path(conn, :index))
  end
end
