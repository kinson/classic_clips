defmodule PickEmWeb.PickEmLive.Profile do
  use PickEmWeb, :live_view

  import PickEmWeb.PickEmLive.Emoji

  alias ClassicClips.PickEm
  alias ClassicClips.PickEm.UserPick
  alias PickEmWeb.PickEmLive.{Theme, User, NotificationComponent}

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = User.get_or_create_user(session)

    theme = Theme.get_theme_from_session(session)

    if is_nil(user) do
      {:ok, push_redirect(socket, to: "/")}
    else
      {:ok,
       socket
       |> assign(:page, "profile")
       |> assign(:theme, theme)
       |> assign(:subscribed_to_email_notifications?, user.email_new_matchups)
       |> assign(:is_missing_picks, PickEm.is_missing_picks_cached?(user))
       |> assign(:picks, PickEm.get_picks_for_user_cached(user))
       |> assign(:user, user)}
    end
  end

  @impl true
  def handle_event("forfeit-missed", _, %{assigns: %{is_missing_picks: false}} = socket) do
    {:noreply, socket}
  end

  def handle_event("forfeit-missed", _, %{assigns: %{user: user}} = socket) do
    ClassicClips.PickEm.forfeit_missed_games(user)

    {:noreply,
     assign(
       socket,
       :is_missing_picks,
       PickEm.is_missing_picks?(user)
     )
     |> assign(
       :picks,
       PickEm.get_picks_for_user(user)
     )
     |> NotificationComponent.show("Sucessfully forfeited missed picks")}
  end

  def handle_event(
        "toggle-email-notifications",
        %{"matchup_emails" => %{"email_notifications" => enabled?}},
        %{assigns: %{user: user}} = socket
      ) do
    user_result =
      case enabled? do
        "true" -> PickEm.enable_matchup_email_notifications(user)
        "false" -> PickEm.disable_matchup_email_notifications(user)
      end

    case user_result do
      {:ok, updated_user} ->
        {:noreply,
         assign(socket, :subscribed_to_email_notifications?, updated_user.email_new_matchups)
         |> assign(:user, updated_user)
         |> NotificationComponent.show("Updated email notification preference")}

      _ ->
        {:noreply, socket}
    end
  end

  def get_matchup_date(%UserPick{matchup: matchup}) do
    %{day: day, month: month, year: year} =
      DateTime.add(matchup.tip_datetime, -1 * PickEm.get_est_offset_seconds())

    "#{month}/#{day}/#{year}"
  end

  def get_matchup_outcome(%UserPick{result: :win}) do
    "WIN"
  end

  def get_matchup_outcome(%UserPick{result: :loss, forfeited_at: nil}) do
    "LOSS"
  end

  def get_matchup_outcome(%UserPick{result: :loss}) do
    "FORFEIT"
  end

  def get_matchup_outcome(_) do
    "PENDING"
  end

  def get_forfeit_button_class(true) do
    "rounded-none bg-nd-pink text-nd-purple font-open-sans mt-4 mb-0 border-none text-2xl ml-10 md:ml-20 hover:bg-nd-pink hover:text-nd-yellow focus:bg-nd-pink focus:text-nd-purple"
  end

  def get_forfeit_button_class(_) do
    get_forfeit_button_class(true) <> " opacity-50 hover:text-nd-purple cursor-default"
  end
end
