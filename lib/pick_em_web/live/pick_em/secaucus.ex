defmodule PickEmWeb.PickEmLive.Secaucus do
  use PickEmWeb, :live_view

  alias ClassicClips.{PickEm, Repo}
  alias ClassicClips.PickEm.{MatchUp, NdcPick}
  alias PickEmWeb.PickEmLive.{Theme, User, NotificationComponent}

  require Logger

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = User.get_or_create_user(session)

    theme = Theme.get_theme_from_session(session)

    current_matchup = PickEm.get_current_matchup()

    todays_matchup = PickEm.get_todays_matchup()

    current_season = PickEm.get_current_season()

    todays_ndc_picks =
      case todays_matchup do
        nil ->
          nil

        %MatchUp{id: id} ->
          Repo.get_by(NdcPick, matchup_id: id)
          |> Repo.preload([:skeets_pick_team, :leigh_pick_team, :trey_pick_team, :tas_pick_team])
      end

    socket =
      socket
      |> assign(:page, "secaucus")
      |> assign(:user, user)
      |> assign(:theme, theme)
      |> assign(:selected_game_id, nil)
      |> assign(:selected_game_line, nil)
      |> assign(:selected_game_tip_datetime, nil)
      |> assign(:selected_game_away_code, nil)
      |> assign(:selected_game_home_code, nil)
      |> assign(:selected_game_favorite_code, nil)
      |> assign(:current_season, current_season)
      |> assign(:current_matchup, current_matchup)
      |> assign(:todays_matchup, todays_matchup)
      |> assign(:ndc_picks, %{})
      |> assign(:todays_ndc_picks, todays_ndc_picks)
      |> assign_matchup_date()
      |> assign_games(Date.utc_today() |> Date.to_iso8601())

    case user do
      %ClassicClips.Timeline.User{role: :super_sicko} ->
        {:ok, socket}

      _ ->
        {:ok,
         push_redirect(socket,
           to: Routes.pick_em_index_path(socket, :index)
         )}
    end
  end

  @impl true
  def handle_event(
        "select-game",
        %{
          "away-team" => away_team_code,
          "home-team" => home_team_code,
          "tip-datetime" => tip_datetime,
          "id" => game_id
        },
        socket
      ) do
    socket =
      socket
      |> assign(:selected_game_id, game_id)
      |> assign(:selected_game_tip_datetime, tip_datetime)
      |> assign(:selected_game_away_code, away_team_code)
      |> assign(:selected_game_home_code, home_team_code)

    {:noreply, socket}
  end

  def handle_event("select-favorite-team", %{"favorite-code" => favorite_team_code}, socket) do
    socket =
      socket
      |> assign(:selected_game_favorite_code, favorite_team_code)

    {:noreply, socket}
  end

  def handle_event(
        "select-ndc-member-pick",
        %{"member" => ndc_member, "team-code" => team_code},
        socket
      ) do
    person = String.to_existing_atom(ndc_member)

    socket =
      socket
      |> assign(:ndc_picks, Map.put(socket.assigns.ndc_picks, person, team_code))

    {:noreply, socket}
  end

  def handle_event(
        "create-matchup",
        %{"matchup" => form_matchup},
        %{
          assigns: %{
            todays_matchup: %{id: _} = todays_matchup,
            todays_ndc_picks: todays_ndc_picks,
            ndc_picks: ndc_picks
          }
        } = socket
      ) do
    # update matchup
    matchup_changes =
      %{
        nba_game_id: form_matchup["game_id"],
        tip_datetime: form_matchup["tip_datetime"],
        spread: form_matchup["game_line"],
        away_team_id: team_id_for_abbreviation(form_matchup["away_team_code"]),
        home_team_id: team_id_for_abbreviation(form_matchup["home_team_code"]),
        favorite_team_id: team_id_for_abbreviation(form_matchup["favorite_team_code"])
      }
      |> Enum.filter(fn {_key, value} ->
        value !== "" and not is_nil(value)
      end)
      |> Enum.into(%{})

    MatchUp.changeset(todays_matchup, matchup_changes)
    |> Repo.update()

    # update ndc picks

    ndc_pick_or_nil = fn name ->
      case Map.get(ndc_picks, name) do
        nil -> nil
        team_abbreviation -> team_id_for_abbreviation(team_abbreviation)
      end
    end

    ndc_changes =
      %{
        skeets_pick_team_id: ndc_pick_or_nil.(:skeets),
        tas_pick_team_id: ndc_pick_or_nil.(:tas),
        leigh_pick_team_id: ndc_pick_or_nil.(:leigh),
        trey_pick_team_id: ndc_pick_or_nil.(:trey)
      }
      |> Enum.filter(fn {_key, value} ->
        value !== "" and not is_nil(value)
      end)
      |> Enum.into(%{})

    NdcPick.changeset(todays_ndc_picks, ndc_changes)
    |> Repo.update()

    # reset picks if different game
    if(form_matchup["game_id"] != todays_matchup.nba_game_id) do
      PickEm.remove_user_picks_for_matchup(todays_matchup)
    end

    updated_matchup = PickEm.set_cached_current_matchup()

    socket =
      socket
      |> assign(:todays_matchup, updated_matchup)
      |> assign(:current_matchup, updated_matchup)
      |> NotificationComponent.show("Updated matchup")

    {:noreply, socket}
  end

  def handle_event(
        "create-matchup",
        %{
          "matchup" => %{
            "game_id" => game_id,
            "tip_datetime" => tip_datetime,
            "favorite_team_code" => favorite_team,
            "away_team_code" => away_team_code,
            "home_team_code" => home_team_code,
            "game_line" => spread
          }
        },
        %{
          assigns: %{
            ndc_picks: %{
              :tas => tas_pick,
              :skeets => skeets_pick,
              :leigh => leigh_pick,
              :trey => trey_pick
            }
          }
        } = socket
      ) do
    case ClassicClips.PickEm.create_matchup(
           away_team_code,
           home_team_code,
           favorite_team,
           spread,
           game_id,
           tip_datetime,
           leigh_pick,
           skeets_pick,
           tas_pick,
           trey_pick
         ) do
      {:ok, _} ->
        matchup = PickEm.get_current_matchup()
        ndc_picks = PickEm.get_ndc_pick_for_matchup(matchup)

        {:noreply,
         socket
         |> assign(:current_matchup, matchup)
         |> assign(:todays_matchup, matchup)
         |> assign(:todays_ndc_picks, ndc_picks)
         |> assign(:current_matchup, PickEm.get_current_matchup())
         |> NotificationComponent.show("Successfully created matchup")}

      _ = error ->
        Logger.error("Could not create new matchup", error: error)

        {:noreply, NotificationComponent.show(socket, "Failed to create matchup", :error)}
    end
  end

  def handle_event("create-matchup", _, socket) do
    {:noreply, NotificationComponent.show(socket, "Could not create matchup", :error)}
  end

  def handle_event(
        "matchup-change-form",
        %{"matchup" => %{"matchup_date" => matchup_date, "game_line" => game_line}},
        socket
      ) do
    {:noreply,
     assign(socket, :selected_game_line, game_line)
     |> assign_games(matchup_date)}
  end

  def handle_event(
        "matchup-change-form",
        %{"matchup" => %{"matchup_date" => matchup_date}},
        socket
      ) do
    {:noreply, assign_games(socket, matchup_date)}
  end

  def handle_event("resend-matchup-email", _, socket) do
    PickEm.notify_sickos(socket.assigns.todays_matchup)
    {:noreply, NotificationComponent.show(socket, "Resent matchup emails")}
  end

  def handle_event("repost-matchup-tweet", _, socket) do
    PickEm.post_matchup_on_twitter(socket.assigns.todays_matchup)
    {:noreply, NotificationComponent.show(socket, "Reposted matchup tweet")}
  end

  defp assign_games(socket, form_matchup_date) do
    form_matchup_date = Date.from_iso8601!(form_matchup_date)
    current_matchup_date = socket.assigns.matchup_date

    if is_nil(Map.get(socket.assigns, :games)) or
         Date.compare(form_matchup_date, current_matchup_date) != :eq do
      games = get_games_for_date(form_matchup_date, socket.assigns.current_season)

      matchup = PickEm.get_matchup_for_day(form_matchup_date)

      socket =
        socket
        |> assign(:games, games)
        |> assign_matchup_date(form_matchup_date)
        |> assign(:current_matchup, matchup)

      if matchup do
        ndc_picks =
          Repo.get_by(NdcPick, matchup_id: matchup.id)
          |> Repo.preload([:skeets_pick_team, :leigh_pick_team, :trey_pick_team, :tas_pick_team])

        socket
        |> assign(:selected_game_id, matchup.nba_game_id)
        |> assign(:selected_game_favorite_code, matchup.favorite_team.abbreviation)
        |> assign(:selected_game_tip_datetime, matchup.tip_datetime)
        |> assign(:selected_game_away_code, matchup.away_team.abbreviation)
        |> assign(:selected_game_home_code, matchup.home_team.abbreviation)
        |> assign(:selected_game_line, matchup.spread)
        |> assign(:todays_ndc_picks, ndc_picks)
      else
        socket
      end
    else
      socket
    end
  end

  defp assign_matchup_date(socket, date \\ Date.utc_today()) do
    assign(socket, :matchup_date, date)
  end

  defp get_matchup_date(matchup_date_string), do: Date.to_iso8601(matchup_date_string)

  defp get_games_for_date(date, current_season) do
    games = ClassicClips.SeasonSchedule.get_games_for_day(current_season.schedule, date)
  end

  def load_games do
    Fiat.CacheServer.fetch_object(
      :todays_games,
      fn ->
        ClassicClips.GameSchedule.get_game_schedule()
      end,
      600
    )
  end

  def team_button_class(team_id, team_id) do
    "border-2 border-white box-border bg-nd-pink w-24 text-center py-2 cursor-pointer"
  end

  def team_button_class(_, _) do
    "border-2 border-transparent box-border bg-nd-pink w-24 text-center py-2 cursor-pointer"
  end

  def game_button_class(game_id, game_id) do
    "border-2 border-white box-border shadow-md flex flex-row bg-nd-pink text-white px-4 py-3 justify-between cursor-pointer"
  end

  def game_button_class(_, _) do
    "border-2 border-transparent box-border shadow-md flex flex-row bg-nd-pink text-white px-4 py-3 justify-between cursor-pointer"
  end

  def get_time_for_game(tip_datetime) do
    DateTime.add(tip_datetime, -1 * PickEm.get_est_offset_seconds())
    |> DateTime.to_time()
    |> Timex.format!("{h12}:{0m} {AM}")
  end

  def game_id_value(nil, %{nba_game_id: nba_game_id}), do: nba_game_id

  def game_id_value(game_id, _), do: game_id

  def tip_datetime_value(nil, %{tip_datetime: tip_datetime}), do: tip_datetime

  def tip_datetime_value(tip_datetime, _), do: tip_datetime

  def favorite_team_code_value(nil, %{favorite_team: %{abbreviation: code}}), do: code

  def favorite_team_code_value(team_code, _), do: team_code

  def away_team_id_value(nil, %{away_team_id: away_team_id}), do: away_team_id

  def away_team_id_value(team_id, _), do: team_id

  def home_team_id_value(nil, %{home_team_id: home_team_id}), do: home_team_id

  def home_team_id_value(team_id, _), do: team_id

  def away_team_code_value(nil, %{away_team: %{abbreviation: abbreviation}}), do: abbreviation

  def away_team_code_value(abbreviation, _), do: abbreviation

  def home_team_code_value(nil, %{home_team: %{abbreviation: abbrevioation}}), do: abbrevioation

  def home_team_code_value(abbreviation, _), do: abbreviation

  def game_line_value(nil, %{spread: spread}), do: spread

  def game_line_value(game_line, _), do: game_line

  def ndc_pick_value(person, form_ndc_picks, nil) do
    Map.get(form_ndc_picks, person)
  end

  def ndc_pick_value(person, form_ndc_picks, todays_ndc_picks) do
    key =
      person
      |> person_to_ndc_picks_key()
      |> String.to_atom()

    case Map.get(form_ndc_picks, person) do
      nil -> Map.get(todays_ndc_picks, key, %{}) |> Map.get(:abbreviation)
      pick -> pick
    end
  end

  defp person_to_ndc_picks_key(person) do
    "#{Atom.to_string(person)}_pick_team"
  end

  def team_id_for_abbreviation("") do
    nil
  end

  def team_id_for_abbreviation(abbreviation) when is_binary(abbreviation) do
    abbreviation |> PickEm.get_cached_team_for_abbreviation() |> Map.get(:id)
  end
end
