defmodule PickEmWeb.ThemeController do
  use PickEmWeb, :controller

  alias ClassicClips.PickEm

  def create(conn, %{"team_emojis" => team_emojis}) do
    emojis_enabled = get_session(conn, :emojis_enabled)
    emojis_only = get_session(conn, :emojis_only)

    emojis_enabled =
      case Map.get(team_emojis, "emojis_enabled") do
        nil -> emojis_enabled || false
        "true" -> true
        "false" -> false
        _ -> false
      end

    emojis_only =
      case Map.get(team_emojis, "emojis_only") do
        nil -> emojis_only || false
        "true" -> true
        "false" -> false
        _ -> false
      end

    put_session(conn, :emojis_enabled, emojis_enabled)
    |> put_session(:emojis_only, emojis_only)
    |> redirect(to: Routes.pick_em_settings_path(conn, :settings))
  end

  def create(conn, %{"custom_emojis" => custom_emojis}) do
    east_teams = PickEm.get_cached_teams_for_conference(:east)
    west_teams = PickEm.get_cached_teams_for_conference(:west)

    custom_emojis =
      custom_emojis
      |> ClassicClips.PickEm.get_custom_team_emojis(east_teams ++ west_teams)

    put_session(conn, :custom_emojis, custom_emojis)
    |> redirect(to: Routes.pick_em_settings_path(conn, :settings))
  end
end
