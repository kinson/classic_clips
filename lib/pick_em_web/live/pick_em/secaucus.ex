defmodule PickEmWeb.PickEmLive.Secaucus do
  use PickEmWeb, :live_view

  alias ClassicClips.{PickEm, Repo}
  alias ClassicClips.PickEm.{MatchUp, NdcPick}
  alias PickEmWeb.PickEmLive.{Theme, User, NotificationComponent}

  require Logger

  @show_no_dunks_picks false

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = User.get_or_create_user(session)

    theme = Theme.get_theme_from_session(session)

    current_matchup = PickEm.get_todays_matchup()

    current_season = PickEm.get_current_season_cached()

    current_ndc_picks =
      PickEm.get_ndc_pick_for_matchup(current_matchup)

    socket =
      socket
      |> assign(:page, "secaucus")
      |> assign(:user, user)
      |> assign(:theme, theme)
      |> assign(:show_no_dunks_picks, @show_no_dunks_picks)
      |> assign(:selected_game_id, nil)
      |> assign(:selected_game_line, nil)
      |> assign(:selected_game_tip_datetime, nil)
      |> assign(:selected_game_away_id, nil)
      |> assign(:selected_game_away_code, nil)
      |> assign(:selected_game_home_id, nil)
      |> assign(:selected_game_home_code, nil)
      |> assign(:selected_game_favorite_id, nil)
      |> assign(:current_season, current_season)
      |> assign(:current_matchup, current_matchup)
      |> assign(:ndc_picks, %{})
      |> assign(:current_ndc_picks, current_ndc_picks)
      |> assign_matchup_date()
      |> assign_games(PickEm.get_current_est_date() |> Date.to_iso8601())

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
          "away-team" => away_team_id,
          "away-team-code" => away_team_code,
          "home-team" => home_team_id,
          "home-team-code" => home_team_code,
          "tip-datetime" => tip_datetime,
          "id" => game_id
        },
        socket
      ) do
    socket =
      socket
      |> assign(:selected_game_id, game_id)
      |> assign(:selected_game_tip_datetime, tip_datetime)
      |> assign(:selected_game_away_id, away_team_id)
      |> assign(:selected_game_away_code, away_team_code)
      |> assign(:selected_game_home_id, home_team_id)
      |> assign(:selected_game_home_code, home_team_code)

    {:noreply, socket}
  end

  def handle_event("select-favorite-team", %{"favorite-id" => favorite_team_id}, socket) do
    socket =
      socket
      |> assign(:selected_game_favorite_id, favorite_team_id)

    {:noreply, socket}
  end

  def handle_event(
        "select-ndc-member-pick",
        %{"member" => ndc_member, "team-id" => team_id},
        socket
      ) do
    person = String.to_existing_atom(ndc_member)

    socket =
      socket
      |> assign(:ndc_picks, Map.put(socket.assigns.ndc_picks, person, team_id))

    {:noreply, socket}
  end

  def handle_event(
        "create-matchup",
        %{"matchup" => form_matchup},
        %{
          assigns: %{
            current_matchup: %{id: _} = current_matchup,
            current_ndc_picks: current_ndc_picks,
            ndc_picks: ndc_picks
          }
        } = socket
      ) do
    # update matchup
    publish_date = form_matchup |> Map.get("publish_at")

    publish_at =
      if publish_date not in [nil, ""] do
        publish_date_string = publish_date <> ":00.000Z"
        {:ok, publish_date_time, _} = DateTime.from_iso8601(publish_date_string)
        DateTime.add(publish_date_time, PickEm.get_est_offset_seconds())
      end

    new_status =
      if form_matchup["publish_now"] == "true" and current_matchup.status == :unpublished,
        do: :published,
        else: current_matchup.status

    matchup_changes =
      %{
        nba_game_id: form_matchup["game_id"],
        publish_at: publish_at,
        status: new_status,
        tip_datetime: form_matchup["tip_datetime"],
        spread: form_matchup["game_line"],
        away_team_id: form_matchup["away_team_id"],
        home_team_id: form_matchup["home_team_id"],
        favorite_team_id: form_matchup["favorite_team_id"]
      }
      |> Enum.filter(fn {_key, value} ->
        value !== "" and not is_nil(value)
      end)
      |> Enum.into(%{})

    {:ok, updated_matchup} =
      current_matchup
      |> MatchUp.changeset(matchup_changes)
      |> Repo.update(returning: true)

    # update ndc picks

    ndc_pick_or_nil = fn name ->
      case Map.get(ndc_picks, name) do
        nil -> nil
        team_id -> team_id
      end
    end

    ndc_changes =
      %{
        skeets_pick_team_id: ndc_pick_or_nil.(:skeets),
        tas_pick_team_id: ndc_pick_or_nil.(:tas),
        trey_pick_team_id: ndc_pick_or_nil.(:trey)
      }
      |> Enum.filter(fn {_key, value} ->
        value !== "" and not is_nil(value)
      end)
      |> Enum.into(%{})

    update_ndc_picks(current_ndc_picks, ndc_changes)

    # reset picks if different game
    if(form_matchup["game_id"] != current_matchup.nba_game_id) do
      PickEm.remove_user_picks_for_matchup(current_matchup)
    end

    socket =
      socket
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
            "favorite_team_id" => favorite_team_id,
            "away_team_id" => away_team_id,
            "home_team_id" => home_team_id,
            "game_line" => spread,
            "publish_at" => publish_at,
            "publish_now" => publish_now
          }
        },
        %{
          assigns: %{
            ndc_picks: ndc_picks
          }
        } = socket
      ) do
    publish_at =
      if publish_at && publish_now != "true" do
        publish_date_string = publish_at <> ":00.000Z"
        {:ok, publish_date_time, _} = DateTime.from_iso8601(publish_date_string)
        DateTime.add(publish_date_time, PickEm.get_est_offset_seconds())
      else
        nil
      end

    status =
      if publish_now == "true",
        do: :published,
        else: :unpublished

    tas_pick = Map.get(ndc_picks, :tas)
    skeets_pick = Map.get(ndc_picks, :skeets)
    trey_pick = Map.get(ndc_picks, :trey)

    case ClassicClips.PickEm.create_matchup(
           away_team_id,
           home_team_id,
           favorite_team_id,
           spread,
           game_id,
           tip_datetime,
           publish_at,
           status,
           skeets_pick,
           tas_pick,
           trey_pick
         ) do
      {:ok, matchup} ->
        ndc_picks = PickEm.get_ndc_pick_for_matchup(matchup)

        {:noreply,
         socket
         |> assign(:current_ndc_picks, ndc_picks)
         |> assign(:current_matchup, matchup)
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
    PickEm.notify_sickos(socket.assigns.current_matchup)
    {:noreply, NotificationComponent.show(socket, "Resent matchup emails")}
  end

  def handle_event("repost-matchup-tweet", _, socket) do
    PickEm.post_matchup_on_twitter(socket.assigns.current_matchup)
    {:noreply, NotificationComponent.show(socket, "Reposted matchup tweet")}
  end

  defp assign_games(socket, form_matchup_date) do
    form_matchup_date = Date.from_iso8601!(form_matchup_date)
    current_matchup_date = socket.assigns.matchup_date

    if is_nil(Map.get(socket.assigns, :games)) or
         Date.compare(form_matchup_date, current_matchup_date) != :eq do
      games = get_games_for_date(form_matchup_date)

      matchup = PickEm.get_matchup_for_day(form_matchup_date)

      socket =
        socket
        |> assign(:games, games)
        |> assign_matchup_date(form_matchup_date)
        |> assign(:current_matchup, matchup)

      if matchup do
        ndc_picks =
          Repo.get_by(NdcPick, matchup_id: matchup.id)
          |> Repo.preload([:skeets_pick_team, :trey_pick_team, :tas_pick_team])

        socket
        |> assign(:selected_game_id, matchup.nba_game_id)
        |> assign(:selected_game_favorite_id, matchup.favorite_team.id)
        |> assign(:selected_game_tip_datetime, matchup.tip_datetime)
        |> assign(:selected_game_away_id, matchup.away_team.id)
        |> assign(:selected_game_away_code, matchup.away_team.abbreviation)
        |> assign(:selected_game_home_id, matchup.home_team.id)
        |> assign(:selected_game_home_code, matchup.home_team.abbreviation)
        |> assign(:selected_game_line, matchup.spread)
        |> assign(:current_ndc_picks, ndc_picks)
        |> assign(:ndc_picks, %{})
      else
        socket
        |> assign(:ndc_picks, %{})
        |> assign(:selected_game_line, nil)
        |> assign(:current_ndc_picks, nil)
        |> assign(:current_matchup, nil)
        |> assign(:selected_game_id, nil)
        |> assign(:selected_game_line, nil)
        |> assign(:selected_game_tip_datetime, nil)
        |> assign(:selected_game_away_id, nil)
        |> assign(:selected_game_away_code, nil)
        |> assign(:selected_game_home_id, nil)
        |> assign(:selected_game_home_code, nil)
        |> assign(:selected_game_favorite_id, nil)
      end
    else
      socket
    end
  end

  defp assign_matchup_date(socket, date \\ PickEm.get_current_est_date()) do
    assign(socket, :matchup_date, date)
  end

  defp get_matchup_date(matchup_date_string),
    do: Date.to_iso8601(matchup_date_string)

  defp get_publish_at_date(nil),
    do: nil

  defp get_publish_at_date(%MatchUp{publish_at: nil}),
    do: nil

  defp get_publish_at_date(%MatchUp{publish_at: publish_at}) do
    # TODO: FIGURE OUT HOW TO CATCH DATE STRING FORMATTING ISSUES
    publish_at
    |> DateTime.add(-1 * PickEm.get_est_offset_seconds())
    |> DateTime.to_iso8601()
    |> String.trim_trailing(":00Z")
  end

  defp get_games_for_date(date) do
    PickEm.get_days_game_cached(date)
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

  defp update_ndc_picks(nil, _), do: {:ok, nil}

  defp update_ndc_picks(ndc_picks, ndc_changes) do
    NdcPick.changeset(ndc_picks, ndc_changes)
    |> Repo.update()
  end

  def team_button_class(team_id, team_id) do
    "border-2 border-white box-border bg-nd-pink w-24 text-center py-2 cursor-pointer"
  end

  def team_button_class(_, _) do
    "border-2 border-transparent box-border bg-nd-pink w-24 text-center py-2 cursor-pointer"
  end

  def game_button_class(game_id, game_id) do
    "border-2 border-white box-border shadow-md flex flex-col bg-nd-pink text-white px-4 py-3 items-center cursor-pointer w-1/4 gap-y-3"
  end

  def game_button_class(_, _) do
    "border-2 border-transparent box-border shadow-md flex flex-col bg-nd-pink text-white px-4 py-3 items-center cursor-pointer w-1/4 gap-y-3"
  end

  def get_status_text_class(nil) do
    ""
  end

  def get_status_text_class(%{status: :unpublished}) do
    "bg-blue-700 text-white px-4 py-1 my-0 ml-12 rounded-md"
  end

  def get_status_text_class(%{status: :completed}) do
    "bg-nd-pink text-white px-4 py-1 my-0 ml-12 rounded-md text-3xl"
  end

  def get_status_text_class(%{status: :published}) do
    "bg-green-600 text-white px-4 py-1 my-0 ml-12 rounded-md text-3xl"
  end

  def get_status_text_class(%{status: :live}) do
    "bg-rose-700 text-white px-4 py-1 my-0 ml-12 rounded-md text-3xl"
  end

  def get_status_text_class(_) do
    "bg-nd-pink text-white px-4 py-1 my-0 ml-4 rounded-md text-3xl"
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

  def favorite_team_id_value(nil, %{favorite_team: %{id: id}}), do: id

  def favorite_team_id_value(team_id, _), do: team_id

  def away_team_id_value(nil, %{away_team_id: away_team_id}), do: away_team_id

  def away_team_id_value(team_id, _), do: team_id

  def home_team_id_value(nil, %{home_team_id: home_team_id}), do: home_team_id

  def home_team_id_value(team_id, _), do: team_id

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
      nil -> Map.get(todays_ndc_picks, key, %{}) |> Map.get(:id)
      pick -> pick
    end
  end

  defp get_matchup_status(nil), do: ""

  defp get_matchup_status(%{status: status}), do: status

  defp show_publish_form(%MatchUp{status: :unpublished}), do: true
  defp show_publish_form(%MatchUp{}), do: false
  defp show_publish_form(nil), do: true

  defp show_notification_buttons(nil), do: false

  defp show_notification_buttons(%MatchUp{status: status})
       when status in [:unpublished, :live, :completed],
       do: false

  defp show_notification_buttons(_), do: true

  defp show_submit_button(%MatchUp{status: status}) when status in [:completed, :live], do: false
  defp show_submit_button(_), do: true

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
