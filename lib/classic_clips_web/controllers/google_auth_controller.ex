defmodule ClassicClipsWeb.GoogleAuthController do
  use ClassicClipsWeb, :controller

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
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
end
