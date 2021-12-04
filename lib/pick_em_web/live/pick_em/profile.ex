defmodule PickEmWeb.PickEmLive.Profile do
  use PickEmWeb, :live_view

  import PickEmWeb.PickEmLive.Emoji

  alias ClassicClips.{Repo, PickEm}
  alias ClassicClips.PickEm.{MatchUp, NdcPick, UserPick, Team}

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = get_or_create_user(session)

    connection_params = get_connect_params(socket) || %{}

    theme =
      case Map.get(connection_params, "theme") do
        nil -> nil
        data -> Jason.decode!(data)
      end

    if is_nil(user) do
      {:ok, push_redirect(socket, to: "/")}
    else
      {:ok,
       socket
       |> assign(:page, "profile")
       |> assign(:theme, theme)
       |> assign(:picks, PickEm.get_picks_for_user(user))
       |> assign(:user, user)}
    end
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

  def get_matchup_date(%UserPick{matchup: matchup}) do
    %{day: day, month: month, year: year} =
      DateTime.add(matchup.tip_datetime, -1 * PickEm.get_est_offset_seconds())

    "#{month}/#{day}/#{year}"
  end

  def get_matchup_outcome(%UserPick{result: :win}) do
    "WIN"
  end

  def get_matchup_outcome(%UserPick{result: :loss}) do
    "LOSS"
  end

  def get_matchup_outcome(_) do
    "PENDING"
  end
end
