defmodule PickEmWeb.PickEmLive.Index do
  use PickEmWeb, :live_view

  import PickEmWeb.PickEmLive.Emoji

  alias ClassicClips.PickEm.{MatchUp, NdcPick, UserPick, Team, NdcRecord}
  alias PickEmWeb.PickEmLive.{Notification, Theme, User}

  @impl true
  def mount(_params, session, socket) do
    matchup = ClassicClips.PickEm.get_cached_current_matchup()

    ndc_pick = ClassicClips.PickEm.get_cached_ndc_pick_for_matchup(matchup)

    ndc_record = ClassicClips.PickEm.get_current_ndc_record()

    matchup_pick_spread = ClassicClips.PickEm.get_cached_pick_spread(matchup)

    {:ok, user} = User.get_or_create_user(session)

    user_pick = ClassicClips.PickEm.get_user_pick_for_matchup(user, matchup)

    {selected_team, selection_saved} = get_selected_team(user_pick)

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
     |> assign(:user_pick, user_pick)
     |> assign(:selected_team, selected_team)
     |> assign(:selection_saved, selection_saved)
     |> assign(:can_save_pick?, can_save_pick?)
     |> assign(:google_auth_url, generate_oauth_url())
     |> assign(:editing_profile, false)}
  end

  @impl true
  def handle_event(_, %{"enabled" => "false"}, socket) do
    {:noreply, socket}
  end

  def handle_event("away-click", _, socket) do
    {:noreply, assign(socket, :selected_team, socket.assigns.matchup.away_team)}
  end

  def handle_event("home-click", _, socket) do
    {:noreply, assign(socket, :selected_team, socket.assigns.matchup.home_team)}
  end

  def handle_event("save-click", _, socket) do
    %{user_pick: user_pick, selected_team: selected_team, user: user, matchup: matchup} =
      socket.assigns

    socket =
      if can_save_pick?(socket.assigns.matchup) do
        case ClassicClips.PickEm.save_user_pick(user_pick, selected_team, user, matchup) do
          {:ok, user_pick} ->
            socket
            |> assign(:user_pick, user_pick)
            |> Notification.show("Saved your pick", :success)

          {:error, _} ->
            Notification.show(socket, "Could not save your pick, please try again", :error)
        end
      else
        socket
      end

    {:noreply, socket}
  end

  def generate_oauth_url do
    %{host: PickEmWeb.Endpoint.host(), port: System.get_env("PORT", "4002")}
    |> ElixirAuthGoogle.generate_oauth_url()
  end

  def get_matchup_title(%MatchUp{
        away_team: away_team,
        home_team: home_team,
        favorite_team: favorite_team,
        spread: spread
      }) do
    "#{away_team.abbreviation} @ #{home_team.abbreviation} (#{favorite_team.abbreviation} #{spread})"
  end

  def get_ndc_pick("skeets", %NdcPick{skeets_pick_team: team}), do: team
  def get_ndc_pick("tas", %NdcPick{tas_pick_team: team}), do: team
  def get_ndc_pick("leigh", %NdcPick{leigh_pick_team: team}), do: team
  def get_ndc_pick("trey", %NdcPick{trey_pick_team: team}), do: team

  def get_time_left(%MatchUp{tip_datetime: tip_datetime} = matchup) do
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

  def can_save_pick?(%MatchUp{tip_datetime: tip_datetime}) do
    DateTime.compare(DateTime.utc_now(), tip_datetime) == :lt
  end

  def get_save_button_text(_, false), do: "Pick No Longer Available"
  def get_save_button_text(false, _), do: "Lock It In"
  def get_save_button_text(true, _), do: "Update Your Pick"

  def maybe_disable(class_string, false), do: class_string <> " opacity-60"
  def maybe_disable(class_string, _), do: class_string <> " shadow-brutal"

  def get_team_button_style(nil, _) do
    get_team_button_class("not selected")
  end

  def get_team_button_style(selected_team, %Team{id: team_id}) do
    if selected_team.id == team_id do
      get_team_button_class("selected")
    else
      get_team_button_class("not selected")
    end
  end

  def get_team_button_class("selected") do
    "#{base_button_class()} bg-nd-pink text-nd-yellow border-2 border-white hover:border-white focus:border-white"
  end

  def get_team_button_class(_) do
    "#{base_button_class()} bg-white text-nd-purple border-0"
  end

  def base_button_class do
    "leading-none rounded-none font-open-sans font-bold text-2xl hover:bg-nd-pink focus:bg-nd-pink w-8/12 md:w-11/24 px-0 flex justify-center items-center"
  end

  defp get_selected_team(nil), do: {nil, false}

  defp get_selected_team(%UserPick{picked_team: picked_team}) do
    {picked_team, true}
  end

  def get_time_for_game(%MatchUp{tip_datetime: tip_datetime}) do
    DateTime.add(tip_datetime, -1 * ClassicClips.PickEm.get_est_offset_seconds())
    |> DateTime.to_time()
    |> Timex.format!("{h12}:{0m} {AM}")
  end

  def get_ndc_record() do
    ClassicClips.PickEm.get_current_ndc_record()
  end

  def get_ndc_record_string(_, nil) do
    "0 - 0"
  end

  def get_ndc_record_string(:tas, %NdcRecord{} = ndc_record) do
    "#{ndc_record.tas_wins} - #{ndc_record.tas_losses}"
  end

  def get_ndc_record_string(:trey, %NdcRecord{} = ndc_record) do
    "#{ndc_record.trey_wins} - #{ndc_record.trey_losses}"
  end

  def get_ndc_record_string(:leigh, %NdcRecord{} = ndc_record) do
    "#{ndc_record.leigh_wins} - #{ndc_record.leigh_losses}"
  end

  def get_ndc_record_string(:skeets, %NdcRecord{} = ndc_record) do
    "#{ndc_record.skeets_wins} - #{ndc_record.skeets_losses}"
  end

  def get_pick_spread_string(pick_spread, %MatchUp{
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

  def get_pick_spread_string(_, _), do: "NO PICK SPREAD YET"
end
