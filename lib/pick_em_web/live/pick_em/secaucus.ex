defmodule PickEmWeb.PickEmLive.Secaucus do
  use PickEmWeb, :live_view

  import PickEmWeb.PickEmLive.Emoji

  alias ClassicClips.PickEm.{MatchUp, NdcPick, UserPick, Team, NdcRecord}
  alias PickEmWeb.PickEmLive.{Theme, User}

  @impl true
  def mount(_params, session, socket) do
    # get user
    {:ok, user} = User.get_or_create_user(session)

    theme = Theme.get_theme_from_session(session)

    games = load_games()

    socket =
      socket
      |> assign(:page, "secaucus")
      |> assign(:games, games)
      |> assign(:user, user)
      |> assign(:theme, theme)
      |> assign(:selected_game_id, nil)
      |> assign(:selected_game_tip_datetime, nil)
      |> assign(:selected_game_away_code, nil)
      |> assign(:selected_game_home_code, nil)
      |> assign(:selected_game_favorite_code, nil)
      |> assign(:ndc_picks, %{})

    {:ok, socket}
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

  def load_games do
    # get games
    {:ok, games} = games()
    games
  end

  def games do
    Fiat.CacheServer.fetch_object(
      :todays_games,
      fn ->
        ClassicClips.BigBeef.Services.Stats.games_or_someshit() |> IO.inspect()
      end,
      600
    )
  end

  def team_button_class(team_id, team_id) do
    "border-2 border-white box-border bg-nd-pink w-24 text-center py-2"
  end

  def team_button_class(_, _) do
    "border-2 border-transparent box-border bg-nd-pink w-24 text-center py-2"
  end

  def game_button_class(game_id, game_id) do
    "border-2 border-white box-border shadow-md flex flex-row bg-nd-pink text-white px-3 py-3 justify-between"
  end

  def game_button_class(_, _) do
    "border-2 border-transparent box-border shadow-md flex flex-row bg-nd-pink text-white px-3 py-3 justify-between"
  end

  def get_time_for_game(tip_datetime) do
    DateTime.add(tip_datetime, -1 * 5 * 60 * 60)
    |> DateTime.to_time()
    |> Timex.format!("{h12}:{0m} {AM}")
  end
end
