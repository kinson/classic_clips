defmodule ClassicClipsWeb.UserLive.Show do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.Timeline
  alias ClassicClips.Timeline.User
  alias ClassicClips.Repo

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = get_or_create_user(session)
    changeset = Timeline.change_user(user)

    pagination = %{limit: 12, offset: 0}
    {clips, pagination} = list_user_clips(user.id, pagination)

    modifed_socket =
      assign(socket, :user, user)
      |> assign(:gooogle_auth_url, generate_oauth_url())
      |> assign(:pagination, pagination)
      |> assign(:clips, clips)
      |> assign(:show_edit, false)
      |> assign(:changeset, changeset)

    {:ok, modifed_socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:clip, Timeline.get_user!(id))}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Timeline.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Timeline.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Username updated successfully")
         |> assign(:show_edit, false)
         |> assign(:user, user)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("show-edit", _value, socket) do
    {:noreply, assign(socket, :show_edit, true)}
  end

  def handle_event(
        "inc_page",
        _,
        %{assigns: %{pagination: %{current_page: current_page, total_pages: total_pages}}} =
          socket
      )
      when current_page >= total_pages,
      do: {:noreply, socket}

  def handle_event(
        "inc_page",
        _,
        %{
          assigns: %{
            clips: old_clips,
            user: user,
            pagination:
              %{
                offset: offset,
                limit: limit,
                current_page: current_page,
                total_pages: total_pages
              } = pagination
          }
        } = socket
      ) do
    if current_page >= total_pages, do: {:noreply, socket}
    {clips, pagination} = list_user_clips(user.id, %{pagination | offset: offset + limit})

    update_subscriptions(socket, old_clips, clips)

    modifed_socket = assign(socket, :clips, clips) |> assign(:pagination, pagination)
    {:noreply, modifed_socket}
  end

  def handle_event("dec_page", _, %{assigns: %{pagination: %{current_page: 1}}} = socket),
    do: {:noreply, socket}

  def handle_event(
        "dec_page",
        _,
        %{
          assigns: %{
            clips: old_clips,
            user: user,
            pagination:
              %{
                offset: offset,
                limit: limit
              } = pagination
          }
        } = socket
      ) do
    {clips, pagination} = list_user_clips(user.id, %{pagination | offset: offset - limit})

    update_subscriptions(socket, old_clips, clips)

    modifed_socket = assign(socket, :clips, clips) |> assign(:pagination, pagination)
    {:noreply, modifed_socket}
  end

  defp page_title(:show), do: "Show Clip"
  defp page_title(:edit), do: "Edit Clip"

  defp get_or_create_user(%{"profile" => profile}) do
    case Repo.get_by(User, email: profile.email) do
      nil -> User.create_user(profile)
      %User{} = user -> {:ok, user}
    end
  end

  defp get_or_create_user(_) do
    {:ok, nil}
  end

  defp generate_oauth_url do
    %{host: ClassicClipsWeb.Endpoint.host(), port: System.get_env("PORT", "4000")}
    |> ElixirAuthGoogle.generate_oauth_url()
  end

  defp list_user_clips(user_id, %{offset: offset, limit: limit} = pagination) do
    {:ok, clips, count} = Timeline.list_user_clips(user_id, pagination)

    {clips, get_pagination_info(count, offset, limit)}
  end

  defp get_pagination_info(count, offset, limit) do
    current_page = floor(offset / limit + 1)
    total_pages = ceil(count / limit)

    %{
      current_page: current_page,
      total_pages: total_pages,
      limit: limit,
      offset: offset,
      count: count
    }
  end

  defp get_email(user) do
    email = user.email
    max_length = 20

    case String.length(email) > max_length do
      true ->
        "#{String.slice(email, 0, max_length) |> String.trim_trailing()}..."

      false ->
        email
    end
  end

  defp update_subscriptions(socket, old_clips, new_clips) do
    unsub_list = Enum.filter(old_clips, &(not Enum.member?(new_clips, &1)))
    sub_list = Enum.filter(new_clips, &(not Enum.member?(old_clips, &1)))

    if connected?(socket), do: Timeline.resubscribe(unsub_list, sub_list)
  end
end
