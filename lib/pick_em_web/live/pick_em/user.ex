defmodule PickEmWeb.PickEmLive.User do
  alias ClassicClips.Repo

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

  def get_truncated_username(%ClassicClips.Timeline.User{username: username}) do
    if String.length(username) > 22 do
      truncated = String.slice(username, 0..19) |> String.trim_trailing()

      "#{truncated}..."
    else
      username
    end
  end
end
