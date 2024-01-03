defmodule ClassicClips.Discord do
  require Logger

  import Ecto.Query

  alias ClassicClips.PickEm
  alias ClassicClips.PickEm.{DiscordToken, MatchUp}
  alias ClassicClips.Repo

  @redirect_uri Application.compile_env!(:classic_clips, :discord_redirect_uri)

  @token_url "https://discord.com/api/oauth2/token"

  def get_post_string(matchup) do
    %{away_team: away, home_team: home, favorite_team: favorite} = matchup

    away_string = ":#{away.abbreviation}: #{away.name}"
    home_string = ":#{home.abbreviation}: #{home.name}"
    favorite_string = ":#{favorite.abbreviation}: #{matchup.spread}"

    est_time =
      matchup.tip_datetime
      |> DateTime.add(-1 * PickEm.get_est_offset_seconds())
      |> DateTime.to_time()
      |> Timex.format!("{h12}:{0m} {AM}")

    # 923235180137812028 is the user role id for the Daily Pick'Em role

    """
    <@&923235180137812028> Today's matchup is live:
    #{away_string} @ #{home_string} (#{favorite_string})
    Make your pick before #{est_time} ET!
    """
  end

  def post_matchup(%MatchUp{status: :published} = matchup) do
    text = get_post_string(matchup)

    if Application.get_env(:classic_clips, :discord_posts_enabled, false) == true do
      send_request(text)
      :ok
    else
      Logger.info("Not posting discord message: #{text}")
    end
  end

  def post_matchup(matchup) do
    Logger.info("Not posting matchup to Discord because it is in #{matchup.status} status")
  end

  defp send_request(text) do
    NewRelic.Instrumented.Task.Supervisor.start_child(
      ClassicClips.TaskSupervisor,
      fn ->
        discord_tokens =
          Repo.all(from dt in DiscordToken, where: dt.expires_at > fragment("now()"))

        body = Jason.encode!(%{content: text})

        Enum.each(discord_tokens, fn dt ->
          NewRelic.Instrumented.HTTPoison.post(dt.webhook_url, body,
            Authorization: dt.webhook_token,
            "Content-Type": "application/json"
          )
        end)
      end
    )
  end

  def get_access_token(code) do
    case NewRelic.Instrumented.HTTPoison.post(
           @token_url,
           {:form,
            [
              client_id: get_discord_client_id(),
              client_secret: get_discord_client_secret(),
              grant_type: "authorization_code",
              code: code,
              redirect_uri: @redirect_uri
            ]}
         ) do
      {:ok, %HTTPoison.Response{body: body}} ->
        Jason.decode!(body)

      {:error, error} ->
        Logger.error("Failed to get Discord token: #{inspect(error)}", error: error)
    end
  end

  def refresh_access_token(%DiscordToken{refresh_token: refresh_token}) do
    case NewRelic.Instrumented.HTTPoison.post(
           @token_url,
           {:form,
            [
              client_id: get_discord_client_id(),
              client_secret: get_discord_client_secret(),
              grant_type: "refresh_token",
              refresh_token: refresh_token
            ]}
         ) do
      {:ok, %HTTPoison.Response{body: body}} ->
        Jason.decode!(body)

      {:error, error} ->
        Logger.error("Failed to post tweet: #{inspect(error)}", error: error)
    end
  end

  def handle_refresh_response(%{"access_token" => _} = payload) do
    expires_at =
      DateTime.add(DateTime.utc_now(), payload["expires_in"], :second)
      |> DateTime.add(-1, :minute)
      |> DateTime.to_iso8601()

    payload =
      payload
      |> Map.take(["access_token", "refresh_token"])
      |> Map.put("expires_at", expires_at)

    {:ok, payload}
  end

  def handle_refresh_response(other) do
    {:error, other}
  end

  def handle_token_response(%{"access_token" => _} = payload) do
    expires_at =
      DateTime.add(DateTime.utc_now(), payload["expires_in"], :second)
      |> DateTime.add(-1, :minute)
      |> DateTime.to_iso8601()

    payload =
      Map.take(payload, ["access_token", "expires_in", "refresh_token"])
      |> Map.merge(%{
        "webhook_channel_id" => payload["webhook"]["channel_id"],
        "webhook_server_id" => payload["webhook"]["guild_id"],
        "webhook_id" => payload["webhook"]["id"],
        "webhook_url" => payload["webhook"]["url"],
        "webhook_token" => payload["webhook"]["token"],
        "expires_at" => expires_at
      })

    {:ok, payload}
  end

  def handle_token_response(other) do
    Logger.error("Got unexpected result from token, instead got: #{inspect(other)}")
    :error
  end

  defp get_discord_client_id do
    Application.fetch_env!(:classic_clips, :discord_client_id)
  end

  defp get_discord_client_secret do
    Application.fetch_env!(:classic_clips, :discord_client_secret)
  end
end
