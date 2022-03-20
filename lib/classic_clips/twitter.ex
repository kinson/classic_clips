defmodule ClassicClips.Twitter do
  require Logger

  @twitter_api_base "https://api.twitter.com/2"

  def post_tweet(text) do
    url = @twitter_api_base <> "/tweets"
    oauth_header = get_oauth_signature(url)

    headers =
      [
        "Content-Type": "application/json",
        Authorization: oauth_header
      ]
      |> IO.inspect(label: "headers")

    case NewRelic.Instrumented.HTTPoison.post(
           url |> IO.inspect(),
           Jason.encode!(%{text: text}) |> IO.inspect(),
           headers |> IO.inspect()
         ) do
      {:ok, %HTTPoison.Response{body: body} = resp} ->
        IO.inspect(resp, label: "something")
        Jason.decode!(body)

      {:error, error} ->
        Logger.error("Failed to post tweet: #{inspect(error)}", error: error)
    end
  end

  defp get_oauth_signature(url) do
    token = Application.fetch_env!(:classic_clips, :twitter_api_token)
    token_secret = Application.fetch_env!(:classic_clips, :twitter_api_token_secret)
    consumer_key = Application.fetch_env!(:classic_clips, :twitter_api_pickem_consumer_key)
    consumer_secret = Application.fetch_env!(:classic_clips, :twitter_api_pickem_consumer_secret)

    {_, _, signature, oauth_params} =
      AuthUtils.sign(
        %{
          token: token,
          token_secret: token_secret,
          consumer_key: consumer_key,
          consumer_secret: consumer_secret
        } |> IO.inspect(),
        url
      ) |> IO.inspect()

    AuthUtils.auth_header(signature, oauth_params) |> IO.inspect()
  end
end
