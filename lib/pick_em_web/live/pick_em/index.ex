defmodule PickEmWeb.PickEmLive.Index do
  use PickEmWeb, :live_view

  alias ClassicClips.Repo
  alias ClassicClips.PickEm.{MatchUp, NdcPick, UserPick, Team}

  @impl true
  def mount(_params, session, socket) do
    # get matchup
    matchup = ClassicClips.PickEm.get_current_matchup()

    # get ndc pick
    ndc_pick = ClassicClips.PickEm.get_ndc_pick_for_matchup(matchup)

    # get user
    {:ok, user} = get_or_create_user(session)

    # get user pick
    user_pick = ClassicClips.PickEm.get_user_pick_for_matchup(user, matchup)

    {selected_team, selection_saved} = get_selected_team(user_pick)

    can_save_pick? = can_save_pick?(matchup)

    total_picks_today = ClassicClips.PickEm.get_pick_count_for_matchup(matchup)

    {:ok,
     socket
     |> assign(:matchup, matchup)
     |> assign(:ndc_pick, ndc_pick)
     |> assign(:user, user)
     |> assign(:user_pick, user_pick)
     |> assign(:selected_team, selected_team)
     |> assign(:selection_saved, selection_saved)
     |> assign(:can_save_pick?, can_save_pick?)
     |> assign(:total_picks_today, total_picks_today)
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
            |> assign(:success_message, "Saved your pick")

          {:error, _} ->
            assign(socket, :error_message, "Could not save your pick, please try again")
        end
      end

    {:noreply, socket}
  end

  def generate_oauth_url do
    %{host: PickEmWeb.Endpoint.host(), port: System.get_env("PORT", "4002")}
    |> ElixirAuthGoogle.generate_oauth_url()
  end

  def get_or_create_user(%{"profile" => profile}) do
    alias ClassicClips.Timeline.User

    case Repo.get_by(User, email: profile.email) do
      nil -> User.create_user(profile)
      %User{} = user -> {:ok, user}
    end
  end

  def get_or_create_user(_) do
    {:ok, nil}
  end

  def get_matchup_title(%MatchUp{
        away_team: away_team,
        home_team: home_team,
        favorite_team: favorite_team,
        spread: spread
      }) do
    "#{away_team.abbreviation} @ #{home_team.abbreviation} (#{favorite_team.abbreviation} #{spread})"
  end

  def get_ndc_pick("skeets", %NdcPick{skeets_pick_team: team}), do: team.abbreviation
  def get_ndc_pick("tas", %NdcPick{tas_pick_team: team}), do: team.abbreviation
  def get_ndc_pick("leigh", %NdcPick{leigh_pick_team: team}), do: team.abbreviation
  def get_ndc_pick("trey", %NdcPick{trey_pick_team: team}), do: team.abbreviation

  def get_time_left(%MatchUp{tip_datetime: tip_datetime} = matchup) do
    if can_save_pick?(matchup) do
      "#{div(DateTime.diff(tip_datetime, DateTime.utc_now()), 60)} minutes left to pick"
    else
      "The time to pick has passed"
    end
  end

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
    "bg-nd-pink text-nd-yellow leading-none border-2 rounded-none font-open-sans font-bold text-2xl border-white hover:border-white focus:border-white hover:bg-nd-pink focus:bg-nd-pink"
  end

  def get_team_button_class(_) do
    "bg-white text-nd-purple leading-none rounded-none font-open-sans font-bold text-2xl border-0 hover:bg-nd-pink focus:bg-nd-pink"
  end

  defp get_selected_team(nil), do: {nil, false}

  defp get_selected_team(%UserPick{picked_team: picked_team}) do
    {picked_team, true}
  end
end
