defmodule PickEmWeb.DiscordAuthController do
  use PickEmWeb, :controller
  use NewRelic.Tracer

  require Logger

  alias ClassicClips.PickEm

  # @redirect_uri "http://localhost:4002/auth/discord/callback"
  @redirect_uri Application.compile_env!(:classic_clips, :discord_redirect_uri)

  @token_url "https://discord.com/api/oauth2/token"

  @doc """
  `index/2` handles the callback from Google Auth API redirect.
  """
  @trace :index
  def index(conn, %{"code" => code}) do
    {:ok, access_token_response} =
      get_access_token(code) |> handle_token_response()

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

  defp get_access_token(code) do
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
        Logger.error("Failed to post tweet: #{inspect(error)}", error: error)
    end
  end

  defp handle_token_response(%{"access_token" => _} = payload) do
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

  defp handle_token_response(other) do
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
