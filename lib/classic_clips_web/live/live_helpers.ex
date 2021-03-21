defmodule ClassicClipsWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  alias ClassicClips.Timeline.User
  alias ClassicClips.{Repo, Timeline}

  @doc """
  Renders a component inside the `ClassicClipsWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, ClassicClipsWeb.ClipLive.FormComponent,
        id: @clip.id || :new,
        action: @live_action,
        clip: @clip,
        return_to: Routes.clip_index_path(@socket, :index) %>
  """
  def live_modal(_socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, ClassicClipsWeb.ModalComponent, modal_opts)
  end

  def get_or_create_user(%{"profile" => profile}) do
    case Repo.get_by(User, email: profile.email) do
      nil -> User.create_user(profile)
      %User{} = user -> {:ok, user}
    end
  end

  def get_or_create_user(_) do
    {:ok, nil}
  end

  def generate_oauth_url do
    %{host: ClassicClipsWeb.Endpoint.host(), port: System.get_env("PORT", "4000")}
    |> ElixirAuthGoogle.generate_oauth_url()
  end

  def get_user_thumbs_up(%User{} = user) do
    Timeline.get_users_clips_vote_total(user)
  end

  def get_user_thumbs_up(nil), do: 0

  def get_user_votes(nil), do: []

  def get_user_votes(%User{} = user) do
    Timeline.list_votes_for_user(user)
  end

  def get_user_saves(%User{} = user) do
    Timeline.list_saves_for_user(user)
  end

  def get_user_saves(nil), do: []
end
