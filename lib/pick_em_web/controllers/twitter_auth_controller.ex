defmodule PickEmWeb.TwitterAuthController do
  use PickEmWeb, :controller
  use NewRelic.Tracer

  alias ClassicClips.Twitter

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  @trace :index
  def index(conn, %{"code" => code}) do
    Twitter.get_access_token(code)
    |> Twitter.save_token_response()

    redirect(conn, to: "/")
  end

  def index(conn, _) do
    redirect(conn,
      external: Twitter.get_authorization_url()
    )
  end
end
