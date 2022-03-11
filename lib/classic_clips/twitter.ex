defmodule ClassicClips.Twitter do
  require Logger

  @twitter_api_base "https://api.twitter.com/2"

  defp get_pick_em_bearer_token do
    Application.fetch_env!(:classic_clips, :twitter_api_pick_em_bearer_token)
  end

  defp post_tweet(text, token) do
    headers =
      [
        "Content-Type": "application/json",
        Authorization: "Bearer #{token}"
      ]
      |> IO.inspect(label: "headers")

    case NewRelic.Instrumented.HTTPoison.post(
           (@twitter_api_base <> "/tweets") |> IO.inspect(),
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

  def post_pick_em_tweet(text) do
    post_tweet(text, get_pick_em_bearer_token())
  end
end
