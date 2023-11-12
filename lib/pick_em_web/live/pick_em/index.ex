defmodule PickEmWeb.PickEmLive.Index do
  use PickEmWeb, :live_view

  import PickEmWeb.PickEmLive.Emoji

  alias Phoenix.LiveView.JS
  alias ClassicClips.PickEm
  alias ClassicClips.PickEm.{MatchUp, NdcPick, UserPick, UserRecord, Team, NdcRecord}
  alias PickEmWeb.PickEmLive.{NotificationComponent, Theme, User}

  @user_picks_results_topic "pick_spread"
  @show_no_dunks_picks false

  @impl true
  def mount(_params, session, socket) do
    matchup = PickEm.get_cached_most_recent_matchup()

    ndc_pick = PickEm.get_cached_ndc_pick_for_matchup(matchup)

    ndc_record = PickEm.get_current_ndc_record_cached()

    matchup_pick_spread = PickEm.get_cached_pick_spread(matchup)

    {:ok, user} = User.get_or_create_user(session)

    existing_user_pick = PickEm.get_user_pick_for_matchup(user, matchup)

    current_user_month_record = PickEm.get_current_month_record(user)

    can_save_pick? = can_save_pick?(matchup)

    theme = Theme.get_theme_from_session(session)

    if connected?(socket) do
      PickEmWeb.Endpoint.subscribe(@user_picks_results_topic)
    end

    {:ok,
     socket
     |> assign(:page, "home")
     |> assign(:theme, theme)
     |> assign(:show_no_dunks_picks, @show_no_dunks_picks)
     |> assign(:matchup, matchup)
     |> assign(:ndc_pick, ndc_pick)
     |> assign(:pick_spread, matchup_pick_spread)
     |> assign(:ndc_record, ndc_record)
     |> assign(:current_user_month_record, current_user_month_record)
     |> assign(:user, user)
     |> assign(:existing_user_pick, existing_user_pick)
     |> assign(:can_save_pick?, can_save_pick?)
     |> assign(:google_auth_url, generate_oauth_url())
     |> assign(:editing_profile, false)}
  end

  @impl true
  def handle_event(_, %{"enabled" => "false"}, socket) do
    {:noreply, socket}
  end

  def handle_event("save-click", %{"value" => "none"}, socket) do
    {:noreply,
     NotificationComponent.show(socket, "Click on a team first to save your pick", :error)}
  end

  def handle_event("save-click", %{"value" => team_abbreviation}, socket) do
    %{existing_user_pick: existing_user_pick, user: user, matchup: matchup} = socket.assigns

    selected_team = get_team_for_abbreviation(team_abbreviation, matchup)

    socket =
      if can_save_pick?(socket.assigns.matchup) do
        case ClassicClips.PickEm.save_user_pick(existing_user_pick, selected_team, user, matchup) do
          {:ok, up} ->
            fresh_pick_spread = PickEm.get_pick_spread(matchup)

            PickEmWeb.Endpoint.broadcast(
              @user_picks_results_topic,
              "picks_updated",
              fresh_pick_spread
            )

            socket
            |> assign(:existing_user_pick, up)
            |> NotificationComponent.show("Saved your pick", :success)

          {:error, _} ->
            NotificationComponent.show(
              socket,
              "Could not save your pick, please try again",
              :error
            )
        end
      else
        NotificationComponent.show(
          socket,
          "Cannot save pick because the game has started!",
          :error
        )
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info(%{event: "picks_updated", payload: fresh_pick_spread}, socket) do
    {:noreply, assign(socket, :pick_spread, fresh_pick_spread)}
  end

  defp generate_oauth_url do
    %{host: PickEmWeb.Endpoint.host(), port: System.get_env("PORT", "4002")}
    |> ElixirAuthGoogle.generate_oauth_url()
  end

  defp get_ndc_pick("skeets", %NdcPick{skeets_pick_team: team}), do: team
  defp get_ndc_pick("tas", %NdcPick{tas_pick_team: team}), do: team
  defp get_ndc_pick("trey", %NdcPick{trey_pick_team: team}), do: team

  defp get_time_left(%MatchUp{tip_datetime: tip_datetime} = matchup) do
    time_left =
      tip_datetime
      |> DateTime.diff(DateTime.utc_now())
      |> div(60)
      |> get_time_left_to_pick_string()

    if can_save_pick?(matchup) do
      "#{time_left} left to pick"
    else
      "The time to pick has passed"
    end
  end

  defp get_time_left_to_pick_string(minutes) when minutes > 120, do: "#{div(minutes, 60)} hours"
  defp get_time_left_to_pick_string(minutes), do: "#{minutes} minutes"

  defp can_save_pick?(%MatchUp{tip_datetime: tip_datetime}) do
    DateTime.compare(DateTime.utc_now(), tip_datetime) == :lt
  end

  defp get_save_button_text(_, false), do: "Pick No Longer Available"
  defp get_save_button_text(nil, _), do: "Lock It In"
  defp get_save_button_text(%UserPick{}, _), do: "Update Your Pick"

  defp maybe_disable(class_string, false), do: class_string <> " opacity-60"
  defp maybe_disable(class_string, _), do: class_string <> " shadow-brutal"

  defp get_user_record(nil), do: "[ 0 - 0 ]"

  defp get_user_record(%UserRecord{wins: wins, losses: losses}) do
    "[ #{wins} - #{losses} ]"
  end

  defp get_picked_team(nil, %{"emojis_enabled" => true} = theme) do
    if Map.get(theme, "emojis_only") do
      "❓"
    else
      "❓ TBD"
    end
  end

  defp get_picked_team(nil, _theme) do
    "TBD"
  end

  defp get_picked_team(%UserPick{picked_team: picked_team}, theme) do
    render_team_abbreviation(picked_team, theme)
  end

  defp get_initial_team_button_class(%UserPick{picked_team_id: id}, %Team{id: id}, can_save_pick?) do
    "#{base_button_class()} bg-nd-pink text-nd-yellow border-2 border-white hover:border-white focus:border-white"
    |> maybe_disable(can_save_pick?)
  end

  defp get_initial_team_button_class(_, _, can_save_pick?) do
    "#{base_button_class()} bg-white text-nd-purple border-0" |> maybe_disable(can_save_pick?)
  end

  defp handle_team_click(js \\ %JS{}, team, abbreviation, can_save_pick?) do
    if can_save_pick? do
      js
      |> JS.set_attribute({"value", abbreviation},
        to: "#save-pick-button"
      )
      |> add_selected_class_to_team(team)
      |> remove_selected_class_from_other_team(team)
    else
      js
    end
  end

  defp add_selected_class_to_team(js, team) do
    js
    |> JS.remove_class("bg-white text-nd-purple border-0", to: "##{team}-team-button")
    |> JS.add_class(
      "bg-nd-pink text-nd-yellow border-2 border-white hover:border-white focus:border-white",
      to: "##{team}-team-button"
    )
  end

  defp remove_selected_class_from_other_team(js, "home"),
    do: remove_selected_class_from_team(js, "away")

  defp remove_selected_class_from_other_team(js, "away"),
    do: remove_selected_class_from_team(js, "home")

  defp remove_selected_class_from_team(js, team) do
    js
    |> JS.remove_class(
      "bg-nd-pink text-nd-yellow border-2 border-white hover:border-white focus:border-white",
      to: "##{team}-team-button"
    )
    |> JS.add_class("bg-white text-nd-purple border-0", to: "##{team}-team-button")
  end

  defp get_team_for_abbreviation(
         abbreviation,
         %MatchUp{away_team: %{abbreviation: abbreviation} = team}
       ),
       do: team

  defp get_team_for_abbreviation(
         abbreviation,
         %MatchUp{home_team: %{abbreviation: abbreviation} = team}
       ),
       do: team

  defp base_button_class do
    "leading-none rounded-none font-open-sans font-bold text-2xl hover:bg-nd-pink focus:bg-nd-pink w-8/12 md:w-11/24 px-0 flex justify-center items-center"
  end

  defp get_time_for_game(%MatchUp{tip_datetime: tip_datetime}) do
    DateTime.add(tip_datetime, -1 * ClassicClips.PickEm.get_est_offset_seconds())
    |> DateTime.to_time()
    |> Timex.format!("{h12}:{0m} {AM}")
  end

  defp get_ndc_record_string(_, nil) do
    "0 - 0"
  end

  defp get_ndc_record_string(:tas, %NdcRecord{} = ndc_record) do
    "#{ndc_record.tas_wins} - #{ndc_record.tas_losses}"
  end

  defp get_ndc_record_string(:trey, %NdcRecord{} = ndc_record) do
    "#{ndc_record.trey_wins} - #{ndc_record.trey_losses}"
  end

  defp get_ndc_record_string(:skeets, %NdcRecord{} = ndc_record) do
    "#{ndc_record.skeets_wins} - #{ndc_record.skeets_losses}"
  end

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

    "transition: all 0.28s ease-in; max-width: #{width_percent * 0.95}%;background: #{background_color};"
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

    "transition: all 0.28s ease-in; max-width: #{50 * 0.95}%;background: #{background_color};"
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
end
