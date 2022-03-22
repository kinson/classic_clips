defmodule ClassicClips.Twitter do
  require Logger

  import Ecto.Query

  alias ClassicClips.Repo
  alias ClassicClips.PickEm.TwitterToken

  @twitter_api_base "https://api.twitter.com/2"

  def post_tweet(text) do
    if Application.get_env(:classic_clips, :twitter_posts_enabled, false) == true do
      send_request(text)
    else
      Logger.info("Not posting tweet: #{text}")
    end
  end

  defp send_request(text) do
    url = @twitter_api_base <> "/tweets"

    headers = [
      "Content-Type": "application/json",
      Authorization: get_auth_header()
    ]

    case NewRelic.Instrumented.HTTPoison.post(url, Jason.encode!(%{text: text}), headers) do
      {:ok, %HTTPoison.Response{body: body}} ->
        Jason.decode!(body)

      {:error, error} ->
        Logger.error("Failed to post tweet: #{inspect(error)}", error: error)
    end
  end

  defp get_auth_header do
    %{access_token: access_token} =
      from(t in TwitterToken, order_by: [desc: t.expires_at], limit: 1)
      |> Repo.one!()
      |> maybe_refresh_token()

    "Bearer #{access_token}"
  end

  defp maybe_refresh_token(%TwitterToken{} = twitter_token) do
    case Map.get(twitter_token, :expires_at)
         |> DateTime.compare(DateTime.utc_now()) do
      :lt -> refresh_token(twitter_token)
      _ -> twitter_token
    end
  end

  def get_access_token(code) do
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

    body
  end

  defp refresh_token(%TwitterToken{refresh_token: refresh_token} = twitter_token) do
    url = @twitter_api_base <> "/oauth2/token"

    {:ok, %HTTPoison.Response{body: body}} =
      HTTPoison.post(
        url,
        {:form,
         [
           refresh_token: refresh_token,
           grant_type: "refresh_token"
         ]},
        Authorization: get_authorization_header()
      )

    save_token_response(body, twitter_token)
  end

  def save_token_response(response_body, twitter_token \\ nil) do
    %{
      "access_token" => access_token,
      "refresh_token" => refresh_token,
      "expires_in" => expires_in
    } = Jason.decode!(response_body)

    expires_at = DateTime.utc_now() |> DateTime.add(expires_in)

    save_token(twitter_token, %{
      access_token: access_token,
      refresh_token: refresh_token,
      expires_at: expires_at
    })
  end

  defp save_token(nil, attrs) do
    TwitterToken.changeset(%TwitterToken{}, attrs)
    |> Repo.insert!(returning: true)
  end

  defp save_token(twitter_token, attrs) do
    TwitterToken.changeset(twitter_token, attrs)
    |> Repo.update!(returning: true)
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

  def get_redirect_uri do
    Application.fetch_env!(:classic_clips, :twitter_auth_callback_url)
  end

  def get_authorization_url do
    "https://twitter.com/i/oauth2/authorize?response_type=code&client_id=#{get_client_id()}&redirect_uri=#{get_redirect_uri()}&scope=users.read%20tweet.read%20tweet.write%20offline.access&state=stategoeshere&code_challenge=challengegoeshere&code_challenge_method=plain"
  end
end
