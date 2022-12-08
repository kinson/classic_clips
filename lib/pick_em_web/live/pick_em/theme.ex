defmodule PickEmWeb.PickEmLive.Theme do
  def get_theme_from_session(session) do
    default_session = default_theme()
    session_variables = Map.take(session, ["emojis_enabled", "emojis_only", "custom_emojis"])

    Map.merge(default_session, session_variables)
  end

  def default_theme do
    %{"emojis_enabled" => false, "emojis_only" => false, "custom_emojis" => %{}}
  end

  def get_emoji_for_team(team, nil), do: team.default_emoji

  def get_emoji_for_team(team, theme) do
    Map.get(theme, "custom_emojis", %{})
    |> Map.get(team.id, team.default_emoji)
  end

  def get_emojis_enabled(nil), do: false

  def get_emojis_enabled(theme) do
    Map.get(theme, "emojis_enabled", false)
  end

  def get_emoji_only_enabled(nil), do: false

  def get_emoji_only_enabled(theme) do
    Map.get(theme, "emojis_only", false)
  end
end
