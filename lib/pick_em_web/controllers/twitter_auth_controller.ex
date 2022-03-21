defmodule PickEmWeb.TwitterAuthController do
  use PickEmWeb, :controller
  use NewRelic.Tracer

  alias ClassicClips.Repo
  alias ClassicClips.PickEm.TwitterToken

  def get_redirect_uri do
    Application.fetch_env!(:classic_clips, :twitter_auth_callback_url)
  end

  def get_client_id do
    Application.fetch_env!(:classic_clips, :twitter_api_oauth_2_client_id)
  end

  def get_client_secret do
    Application.fetch_env!(:classic_clips, :twitter_api_oauth_2_client_secret)
  end

  def get_authorization_header do
    "Basic " <> Base.encode64(get_client_id() <> ":" <> get_client_secret())
  end

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  @trace :index
  def index(conn, %{"code" => code}) do
    {:ok, %HTTPoison.Response{body: body}} =
      HTTPoison.post(
        "https://api.twitter.com/2/oauth2/token",
        {:form,
         [
           redirect_uri: get_redirect_uri(),
           code: code,
           grant_type: "authorization_code",
           code_verifier: "challengegoeshere",
           client_id: get_client_id()
         ]},
        Authorization: get_authorization_header()
      )

    %{
      "access_token" => access_token,
      "refresh_token" => refresh_token,
      "expires_in" => expires_in
    } = Jason.decode!(body)

    expires_at = DateTime.utc_now() |> DateTime.add(expires_in)

    token =
      TwitterToken.changeset(%TwitterToken{}, %{
        access_token: access_token,
        refresh_token: refresh_token,
        expires_at: expires_at
      })

    Repo.insert!(token)

    redirect(conn, to: "/")
  end

  def index(conn, _) do
    redirect(conn,
      external:
        "https://twitter.com/i/oauth2/authorize?response_type=code&client_id=#{get_client_id()}&redirect_uri=#{get_redirect_uri()}&scope=users.read%20tweet.read%20tweet.write%20offline.access&state=stategoeshere&code_challenge=challengegoeshere&code_challenge_method=plain"
    )
  end
end
