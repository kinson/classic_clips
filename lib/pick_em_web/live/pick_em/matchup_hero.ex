defmodule PickEmWeb.PickEmLive.MatchupHero do
  use PickEmWeb, :live_view
  import PickEmWeb.PickEmLive.Emoji

  alias ClassicClips.PickEm
  alias PickEmWeb.PickEmLive.{Theme, User}
  alias ClassicClips.PickEm.MatchUp
  alias ClassicClips.PickEm.NdcRecord
  alias ClassicClips.BigBeef.Season

  @user_picks_results_topic "pick_spread"

  @impl true
  def mount(_params, session, socket) do
    theme = Theme.default_theme()
    ndc_record = PickEm.get_current_ndc_record_cached()

    if connected?(socket) do
      PickEmWeb.Endpoint.subscribe(@user_picks_results_topic)
    end

    {:ok,
     socket
     |> assign(:page, "matchup-hero")
     |> assign(:ndc_record, ndc_record)
     |> assign(:theme, theme)}
  end

  @impl true
  def handle_params(%{"matchup_id" => matchup_id}, _, socket) do
    matchup = PickEm.get_matchup_by_id(matchup_id)
    matchup_pick_spread = PickEm.get_cached_pick_spread(matchup)

    {:noreply, assign(socket, :matchup, matchup) |> assign(:pick_spread, matchup_pick_spread)}
  end

  @impl true
  def handle_info(%{event: "picks_updated", payload: fresh_pick_spread}, socket) do
    {:noreply, assign(socket, :pick_spread, fresh_pick_spread)}
  end

  defp render_game_spread(%MatchUp{
         spread: "-" <> spread,
         away_team_id: team_id,
         favorite_team_id: team_id
       }) do
    "(+#{spread})"
  end

  defp render_game_spread(%MatchUp{
         spread: "-" <> spread,
         home_team_id: team_id,
         favorite_team_id: team_id
       }) do
    "(-#{spread})"
  end

  defp render_ndc_pick_image(%MatchUp{away_team_id: team_id, away_team: away_team}, team_id) do
    "/images/#{away_team.abbreviation}_LOGO.png"
  end

  defp render_ndc_pick_image(%MatchUp{home_team_id: team_id, home_team: home_team}, team_id) do
    "/images/#{home_team.abbreviation}_LOGO.png"
  end

  defp get_ndc_record_string(_, nil) do
    "0-0"
  end

  defp get_ndc_record_string(:tas, %NdcRecord{} = ndc_record) do
    "#{ndc_record.tas_wins}-#{ndc_record.tas_losses}"
  end

  defp get_ndc_record_string(:trey, %NdcRecord{} = ndc_record) do
    "#{ndc_record.trey_wins}-#{ndc_record.trey_losses}"
  end

  defp get_ndc_record_string(:skeets, %NdcRecord{} = ndc_record) do
    "#{ndc_record.skeets_wins}-#{ndc_record.skeets_losses}"
  end

  defp show_pick_spread?(%{} = ps) do
    case Map.keys(ps) do
      [] -> false
      _ -> true
    end
  end

  # TODO MOVE TO COMMON MODULE
  defp get_pick_spread_total(pick_spread), do: "PICKS: #{Map.values(pick_spread) |> Enum.sum()}"

  defp get_pick_spread_string(
         pick_spread,
         %MatchUp{
           away_team_id: away_team_id,
           home_team_id: home_team_id
         } = matchup
       )
       when is_map_key(pick_spread, away_team_id) or is_map_key(pick_spread, home_team_id) do
    away_picks = Map.get(pick_spread, away_team_id, 0)
    home_picks = Map.get(pick_spread, home_team_id, 0)
    total = away_picks + home_picks

    away_percent = round(away_picks / total * 100)
    home_percent = round(home_picks / total * 100)

    home_percent = get_rounded_percent(away_percent + home_percent, home_percent)

    away_name = matchup.away_team.abbreviation
    home_name = matchup.home_team.abbreviation

    "#{away_percent}% #{away_name} @ #{home_percent}% #{home_name}"
  end

  defp get_pick_spread_string(_, _), do: "NO PICK SPREAD YET"

  defp get_rounded_percent(100, percent), do: percent
  defp get_rounded_percent(99, percent), do: percent + 1
  defp get_rounded_percent(101, percent), do: percent - 1

  defp get_pick_spread_gradient(
         pick_spread,
         %MatchUp{
           away_team_id: away_team_id,
           home_team_id: home_team_id
         } = matchup,
         away_or_home
       )
       when is_map_key(pick_spread, away_team_id) or is_map_key(pick_spread, home_team_id) do
    away_picks = Map.get(pick_spread, away_team_id, 0)
    home_picks = Map.get(pick_spread, home_team_id, 0)
    total = away_picks + home_picks

    [away_color, home_color] =
      get_team_colors(
        String.to_atom(matchup.away_team.abbreviation),
        String.to_atom(matchup.home_team.abbreviation)
      )

    away_percent = away_picks / total * 100
    home_percent = home_picks / total * 100

    width_percent = if away_or_home == :away, do: away_percent, else: home_percent
    background_color = if away_or_home == :away, do: away_color, else: home_color

    width_percent = width_percent |> max(1) |> min(99)

    "transition: all 0.28s ease-in; max-width: #{width_percent}%;background: #{background_color};"
  end

  defp get_pick_spread_gradient(
         _,
         matchup,
         away_or_home
       ) do
    [away_color, home_color] =
      get_team_colors(
        String.to_atom(matchup.away_team.abbreviation),
        String.to_atom(matchup.home_team.abbreviation)
      )

    background_color = if away_or_home == :away, do: away_color, else: home_color

    "transition: all 0.28s ease-in; max-width: 50%;background: #{background_color};"
  end

  defp get_team_colors(away, home) do
    home_colors = get_team_color_codes(home)
    away_colors = get_team_color_codes(away)

    cond do
      colors_contrast_enough?(away_colors.primary_l, home_colors.primary_l) ->
        [away_colors.primary, home_colors.primary]

      colors_contrast_enough?(away_colors.primary_l, home_colors.secondary_l) ->
        [away_colors.primary, home_colors.secondary]

      colors_contrast_enough?(away_colors.secondary_l, home_colors.primary_l) ->
        [away_colors.secondary, home_colors.primary]

      true ->
        [away_colors.secondary, home_colors.secondary]
    end
  end

  defp colors_contrast_enough?(l1, l2) when l1 > l2 do
    (l1 + 0.05) / (l2 + 0.05) > 1.9
  end

  defp colors_contrast_enough?(l1, l2) do
    (l2 + 0.05) / (l1 + 0.05) > 1.9
  end

  defp get_team_color_codes(team) do
    colors = %{
      ATL: %{primary: "#C8102E", primary_l: 57.3, secondary: "#FDB927", secondary_l: 188.9},
      BKN: %{primary: "#000000", primary_l: 21.6, secondary: "#FFFFFF", secondary_l: 255},
      BOS: %{primary: "#007A33", primary_l: 90.9, secondary: "#BA9653", secondary_l: 114.6},
      CHA: %{primary: "#1D1160", primary_l: 25.3, secondary: "#00788C", secondary_l: 95.9},
      CHI: %{primary: "#CE1141", primary_l: 60.6, secondary: "#000000", secondary_l: 21.6},
      CLE: %{primary: "#860038", primary_l: 32.5, secondary: "#FDBB30", secondary_l: 191.0},
      DAL: %{primary: "#00538C", primary_l: 72.9, secondary: "#002B5E", secondary_l: 37.4},
      DEN: %{primary: "#0E2240", primary_l: 31.7, secondary: "#FEC524", secondary_l: 198.6},
      DET: %{primary: "#C8102E", primary_l: 64.5, secondary: "#1D42BA", secondary_l: 63.3},
      GSW: %{primary: "#1D428A", primary_l: 63.3, secondary: "#FFC72C", secondary_l: 199.7},
      HOU: %{primary: "#CE1141", primary_l: 60.6, secondary: "#000000", secondary_l: 21.6},
      IND: %{primary: "#002D62", primary_l: 39.3, secondary: "#FDBB30", secondary_l: 191.0},
      LAC: %{primary: "#C8102E", primary_l: 57.3, secondary: "#1D428A", secondary_l: 64.1},
      LAL: %{primary: "#552583", primary_l: 53.9, secondary: "#FDB927", secondary_l: 188.9},
      MEM: %{primary: "#5D76A9", primary_l: 116.4, secondary: "#12173F", secondary_l: 24.8},
      MIA: %{primary: "#98002E", primary_l: 35.6, secondary: "#F9A01B", secondary_l: 169.3},
      MIL: %{primary: "#00471B", primary_l: 52.7, secondary: "#EEE1C6", secondary_l: 234.3},
      MIN: %{primary: "#0C2340", primary_l: 32.2, secondary: "#236192", secondary_l: 87.4},
      NOP: %{primary: "#0C2340", primary_l: 32.2, secondary: "#C8102E", secondary_l: 57.3},
      NYK: %{primary: "#006BB6", primary_l: 89.7, secondary: "#F58426", secondary_l: 149.2},
      OKC: %{primary: "#007AC1", primary_l: 103.5, secondary: "#EF3B24", secondary_l: 95.6},
      ORL: %{primary: "#0077C0", primary_l: 103.6, secondary: "#C4CED4", secondary_l: 204.2},
      PHI: %{primary: "#006BB6", primary_l: 89.7, secondary: "#ED174C", secondary_l: 72.3},
      PHX: %{primary: "#1D1160", primary_l: 25.3, secondary: "#E56020", secondary_l: 118.9},
      POR: %{primary: "#E03A3E", primary_l: 93.6, secondary: "#000000", secondary_l: 21.6},
      SAC: %{primary: "#5A2D81", primary_l: 59.5, secondary: "#63727A", secondary_l: 110.7},
      SAS: %{primary: "#C4CED4", primary_l: 204.2, secondary: "#000000", secondary_l: 21.6},
      TOR: %{primary: "#CE1141", primary_l: 60.6, secondary: "#000000", secondary_l: 21.6},
      UTA: %{primary: "#002B5C", primary_l: 37.4, secondary: "#00471B", secondary_l: 52.7},
      WAS: %{primary: "#002B5C", primary_l: 37.4, secondary: "#E31837", secondary_l: 69.4}
    }

    Map.get(colors, team)
  end
end
