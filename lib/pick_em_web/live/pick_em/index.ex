defmodule PickEmWeb.PickEmLive.Index do
  use PickEmWeb, :live_view

  import PickEmWeb.PickEmLive.Emoji

  alias Phoenix.LiveView.JS
  alias ClassicClips.PickEm.{MatchUp, NdcPick, UserPick, Team, NdcRecord}
  alias PickEmWeb.PickEmLive.{NotificationComponent, Theme, User}

  @impl true
  def mount(_params, session, socket) do
    matchup = ClassicClips.PickEm.get_cached_most_recent_matchup()

    ndc_pick = ClassicClips.PickEm.get_cached_ndc_pick_for_matchup(matchup)

    ndc_record = ClassicClips.PickEm.get_current_ndc_record()

    matchup_pick_spread = ClassicClips.PickEm.get_cached_pick_spread(matchup)

    {:ok, user} = User.get_or_create_user(session)

    existing_user_pick = ClassicClips.PickEm.get_user_pick_for_matchup(user, matchup)

    can_save_pick? = can_save_pick?(matchup)

    theme = Theme.get_theme_from_session(session)

    {:ok,
     socket
     |> assign(:page, "home")
     |> assign(:theme, theme)
     |> assign(:matchup, matchup)
     |> assign(:ndc_pick, ndc_pick)
     |> assign(:pick_spread, matchup_pick_spread)
     |> assign(:ndc_record, ndc_record)
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

  defp get_pick_spread_string(pick_spread, %MatchUp{
         away_team_id: away_team_id,
         home_team_id: home_team_id
       })
       when is_map_key(pick_spread, away_team_id) and is_map_key(pick_spread, home_team_id) do
    away_picks = Map.get(pick_spread, away_team_id, 0)
    home_picks = Map.get(pick_spread, home_team_id, 0)
    total = away_picks + home_picks

    away_percent = round(away_picks / total * 100)
    home_percent = round(home_picks / total * 100)

    "PICK SPREAD #{away_percent}% @ #{home_percent}%"
  end

  defp get_pick_spread_string(_, _), do: "NO PICK SPREAD YET"
end
