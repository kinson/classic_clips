defmodule PickEmWeb.PickEmLive.Secaucus do
  use PickEmWeb, :live_view

  alias ClassicClips.PickEm
  alias PickEmWeb.PickEmLive.{Theme, User}

  @impl true
  def mount(_params, session, socket) do
    # get user
    {:ok, user} = User.get_or_create_user(session)

    theme = Theme.get_theme_from_session(session)

    games = load_games()

    current_matchup = PickEm.get_current_matchup()

    socket =
      socket
      |> assign(:page, "secaucus")
      |> assign(:games, games)
      |> assign(:user, user)
      |> assign(:theme, theme)
      |> assign(:message, nil)
      |> assign(:error, nil)
      |> assign(:selected_game_id, nil)
      |> assign(:selected_game_tip_datetime, nil)
      |> assign(:selected_game_away_code, nil)
      |> assign(:selected_game_home_code, nil)
      |> assign(:selected_game_favorite_code, nil)
      |> assign(:current_matchup, current_matchup)
      |> assign(:ndc_picks, %{})

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
    socket =
      socket
      |> assign(:ndc_picks, Map.put(socket.assigns.ndc_picks, ndc_member, team_code))

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
              "tas" => tas_pick,
              "skeets" => skeets_pick,
              "leigh" => leigh_pick,
              "trey" => trey_pick
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
        {:noreply,
         socket
         |> assign(:current_matchup, PickEm.get_current_matchup())
         |> assign(:message, "Successfully created matchup")
         |> assign(:error, nil)}

      _ ->
        {:noreply,
         socket
         |> assign(:error, "Failed to create matchup")
         |> assign(:message, nil)}
    end
  end

  def handle_event("create-matchup", _, socket) do
    {:noreply, assign(socket, :error, "Failed to create matchup")}
  end

  def load_games do
    # get games
    {:ok, games} = games()
    games
  end

  def games do
    Fiat.CacheServer.fetch_object(
      :todays_games,
      fn ->
        ClassicClips.BigBeef.Services.Stats.games_or_someshit()
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
    DateTime.add(tip_datetime, -1 * 5 * 60 * 60)
    |> DateTime.to_time()
    |> Timex.format!("{h12}:{0m} {AM}")
  end
end
