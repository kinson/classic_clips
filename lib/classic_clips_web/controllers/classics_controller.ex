defmodule ClassicClipsWeb.ClassicsController do
  use ClassicClipsWeb, :controller

  alias ClassicClips.Timeline
  alias ClassicClips.Timeline.User
  alias ClassicClips.Repo

  def index(conn, _params) do
    {:ok, user} =
      Plug.Conn.get_session(conn, :profile)
      |> get_or_create_user()

    classics = ClassicClips.Classics.list_recent_videos()

    conn
    |> assign(:user, user)
    |> assign(:gooogle_auth_url, generate_oauth_url())
    |> assign(:thumbs_up_total, get_user_thumbs_up(user))
    |> assign(:classics, classics)
    |> assign(:page_title, "Classics")
    |> render(:index)
  end

  defp generate_oauth_url do
    %{host: ClassicClipsWeb.Endpoint.host(), port: System.get_env("PORT", "4000")}
    |> ElixirAuthGoogle.generate_oauth_url()
  end

  defp get_or_create_user(nil) do
    {:ok, nil}
  end

  defp get_or_create_user(profile) do
    case Repo.get_by(User, email: profile.email) do
      nil -> User.create_user(profile)
      %User{} = user -> {:ok, user}
    end
  end

  defp get_user_thumbs_up(%User{} = user) do
    Timeline.get_users_clips_vote_total(user)
  end

  defp get_user_thumbs_up(nil), do: 0
end
