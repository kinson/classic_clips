defmodule PickEmWeb.PickEmLive.Emoji do
  import Phoenix.LiveView.Helpers

  def render_team_name(team, theme, p_class \\ "") do
    render_team_string(team.name, emoji_for_team(team, theme), p_class, theme)
  end

  def render_team_abbreviation(team, theme, p_class \\ "") do
    render_team_string(team.abbreviation, emoji_for_team(team, theme), p_class, theme)
  end

  def render_team_location(team, theme, p_class \\ "") do
    render_team_string(team.location, emoji_for_team(team, theme), p_class, theme)
  end

  def render_team_string(attr, _emoji, p_class, %{"enable_emojis" => false}) do
    assigns = %{attr: attr, p_class: p_class}

    ~H"""
    <div class="flex flex-row gap-4 w-max">
       <p class={"my-0 mx-0 font-open-sans #{@p_class}"}><%= @attr %></p>
    </div>
    """
  end

  def render_team_string(attr, emoji, p_class, %{
        "enable_emojis" => true,
        "enable_emoji_only" => false
      }) do
    assigns = %{emoji: emoji, attr: attr, p_class: p_class}

    ~H"""
    <div class="flex flex-row gap-4 w-max">
       <p class={"my-0 mx-0 font-open-sans #{@p_class}"}><%= @emoji %></p>
       <p class={"my-0 mx-0 font-open-sans #{@p_class}"}><%= @attr %></p>
    </div>
    """
  end

  def render_team_string(_attr, emoji, p_class, %{
        "enable_emojis" => true,
        "enable_emoji_only" => true
      }) do
    assigns = %{emoji: emoji, p_class: p_class}

    ~H"""
    <div class="flex flex-row gap-4 w-max">
       <p class={"my-0 mx-0 font-open-sans #{@p_class}"}><%= @emoji %></p>
    </div>
    """
  end

  def render_team_string(attr, _emoji, _) do
    assigns = %{attr: attr}

    ~H"""
    <div class="flex flex-row gap-4 w-max">
       <p class="my-0 mx-0 font-open-sans"><%= @attr %></p>
    </div>
    """
  end

  def emoji_for_team(team, nil), do: team.default_emoji

  def emoji_for_team(team, theme) do
    Map.get(theme, "emoji_overrides", %{})
    |> Map.get(team.id, team.default_emoji)
  end
end
