defmodule PickEmWeb.PickEmLive.Emoji do
  import Phoenix.LiveView.Helpers

  alias PickEmWeb.PickEmLive.Theme

  def render_team_name(team, theme, p_class \\ "") do
    render_team_string(team.name, Theme.get_emoji_for_team(team, theme), p_class, theme)
  end

  def render_team_abbreviation(team, theme, p_class \\ "") do
    render_team_string(team.abbreviation, Theme.get_emoji_for_team(team, theme), p_class, theme)
  end

  def render_team_location(team, theme, p_class \\ "") do
    render_team_string(team.location, Theme.get_emoji_for_team(team, theme), p_class, theme)
  end

  def render_team_string(attr, _emoji, p_class, %{"emojis_enabled" => false}) do
    assigns = %{attr: attr, p_class: p_class}

    ~H"""
    <div class="flex flex-row gap-4 w-max">
      <p class={"my-0 mx-0 font-open-sans #{@p_class}"}>
        <%= @attr %>
      </p>
    </div>
    """
  end

  def render_team_string(attr, emoji, p_class, %{
        "emojis_enabled" => true,
        "emojis_only" => false
      }) do
    assigns = %{emoji: emoji, attr: attr, p_class: p_class}

    ~H"""
    <div class="flex flex-row gap-4 w-max">
      <p class={"my-0 mx-0 font-open-sans #{@p_class}"}>
        <%= @emoji %>
      </p>
      <p class={"my-0 mx-0 font-open-sans #{@p_class}"}>
        <%= @attr %>
      </p>
    </div>
    """
  end

  def render_team_string(_attr, emoji, p_class, %{
        "emojis_enabled" => true,
        "emojis_only" => true
      }) do
    assigns = %{emoji: emoji, p_class: p_class}

    ~H"""
    <div class="flex flex-row gap-4 w-max">
      <p class={"my-0 mx-0 font-open-sans #{@p_class}"}>
        <%= @emoji %>
      </p>
    </div>
    """
  end

  def render_team_string(attr, _emoji, _) do
    assigns = %{attr: attr}

    ~H"""
    <div class="flex flex-row gap-4 w-max">
      <p class="my-0 mx-0 font-open-sans">
        <%= @attr %>
      </p>
    </div>
    """
  end
end
