defmodule ClassicClips.Discord do
  require Logger

  import Ecto.Query

  alias ClassicClips.PickEm
  alias ClassicClips.PickEm.DiscordToken
  alias ClassicClips.Repo

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

  def post_matchup(matchup) do
    text = get_post_string(matchup)

    if Application.get_env(:classic_clips, :discord_posts_enabled, false) == true do
      send_request(text)
      :ok
    else
      Logger.info("Not posting discord message: #{text}")
    end
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
end
