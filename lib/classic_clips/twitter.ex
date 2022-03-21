defmodule ClassicClips.Twitter do
  require Logger

  import Ecto.Query

  alias ClassicClips.Repo
  alias ClassicClips.PickEm.TwitterToken

  @twitter_api_base "https://api.twitter.com/2"

  def post_tweet(text) do
    url = @twitter_api_base <> "/tweets"

    headers =
      [
        "Content-Type": "application/json",
        Authorization: get_auth_header()
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

  def get_auth_header do
    %{access_token: access_token} =
      Repo.one!(from t in TwitterToken, order_by: [desc: t.expires_at], limit: 1)

    "Bearer #{access_token}"
  end
end
