defmodule ClassicClipsWeb.ClipLive.Index do
  use ClassicClipsWeb, :live_view

  alias ClassicClips.{Repo, Timeline}
  alias ClassicClips.Timeline.{Clip, User}

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = get_or_create_user(session)
    pagination = %{limit: 12, offset: 0}
    category = "today"
    {clips, pagination} = list_top_clips(category, pagination)

    if connected?(socket), do: Timeline.subscribe(clips)

    modified_socket =
      socket
      |> assign(:page_title, "Classic Clips")
      |> assign(:user, user)
      |> assign(:clips, clips)
      |> assign(:category, category)
      |> assign(:pagination, pagination)
      |> assign(:votes, get_user_votes(user))
      |> assign(:saves, get_user_saves(user))
      |> assign(:gooogle_auth_url, generate_oauth_url())

    {:ok, modified_socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:clip, Timeline.get_clip!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:clip, %Clip{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:clip, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    clip = Timeline.get_clip!(id)
    {:ok, _} = Timeline.delete_clip(clip)

    {:noreply, assign(socket, :clips, list_top_clips(socket.assigns.pagination))}
  end

  def handle_event("change_sort", %{"sort" => %{"timeframe" => "new"}}, socket) do
    {clips, pagination} = list_new_clips(socket.assigns.pagination)

    modified_socket =
      assign(socket, :clips, clips)
      |> assign(:pagination, pagination)
      |> assign(:category, "new")

    {:noreply, modified_socket}
  end

  def handle_event("change_sort", %{"sort" => %{"timeframe" => sort_timeframe}}, socket) do
    {clips, pagination} = list_top_clips(sort_timeframe, socket.assigns.pagination)

    modified_socket =
      assign(socket, :clips, clips)
      |> assign(:pagination, pagination)
      |> assign(:category, sort_timeframe)

    {:noreply, modified_socket}
  end

  def handle_event("change_search", %{"search" => %{"term" => search_term}}, socket) do
    IO.inspect search_term

    {:noreply, socket}
  end

  def handle_event(
        "inc_votes",
        %{"clip" => clip_id},
        %{assigns: %{votes: votes, user: user}} = socket
      ) do
    case Timeline.can_vote?(clip_id, votes, user) do
      true ->
        {:ok, vote} = ClassicClips.Timeline.inc_votes(clip_id, user)
        {:noreply, assign(socket, :votes, [vote | votes])}

      false ->
        {:noreply, socket}
    end
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
            category: "new",
            clips: old_clips,
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
    {clips, pagination} = list_new_clips(%{pagination | offset: offset + limit})

    update_subscriptions(socket, old_clips, clips)

    modifed_socket = assign(socket, :clips, clips) |> assign(:pagination, pagination)
    {:noreply, modifed_socket}
  end

  def handle_event(
        "inc_page",
        _,
        %{
          assigns: %{
            category: category,
            clips: old_clips,
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
    {clips, pagination} = list_top_clips(category, %{pagination | offset: offset + limit})

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
            category: "new",
            clips: old_clips,
            pagination:
              %{
                offset: offset,
                limit: limit
              } = pagination
          }
        } = socket
      ) do
    {clips, pagination} = list_new_clips(%{pagination | offset: offset - limit})

    update_subscriptions(socket, old_clips, clips)

    modifed_socket = assign(socket, :clips, clips) |> assign(:pagination, pagination)
    {:noreply, modifed_socket}
  end

  def handle_event(
        "dec_page",
        _,
        %{
          assigns: %{
            category: category,
            clips: old_clips,
            pagination:
              %{
                offset: offset,
                limit: limit
              } = pagination
          }
        } = socket
      ) do
    {clips, pagination} = list_top_clips(category, %{pagination | offset: offset - limit})

    update_subscriptions(socket, old_clips, clips)

    modifed_socket = assign(socket, :clips, clips) |> assign(:pagination, pagination)
    {:noreply, modifed_socket}
  end

  def handle_event("save_clip", %{"clip" => clip_id}, %{assigns: %{
    saves: saves,
    user: user
  }} = socket) do
    {:ok, new_saves} = update_saves(saves, clip_id, user.id)

    {:noreply, assign(socket, :saves, new_saves)}
  end

  @impl true
  # def handle_info({:clip_created, clip}, socket) do
  #   {:noreply, update(socket, :clips, fn clips -> clips end)}
  # end

  def handle_info({:clip_updated, clip}, socket) do
    {:noreply,
     update(socket, :clips, fn clips ->
       Enum.map(clips, &if(&1.id == clip.id, do: clip, else: &1))
     end)}
  end

  defp list_top_clips(pagination) do
    list_top_clips("today", pagination)
  end

  defp list_top_clips(timeframe, %{offset: offset, limit: limit} = pagination) do
    {:ok, clips, count} = Timeline.list_top_clips_by_date(timeframe, pagination)

    {clips, get_pagination_info(count, offset, limit)}
  end

  defp list_new_clips(%{limit: limit, offset: offset} = pagination) do
    {:ok, clips, count} = Timeline.list_newest_clips(pagination)

    {clips, get_pagination_info(count, offset, limit)}
  end

  defp generate_oauth_url do
    %{host: ClassicClipsWeb.Endpoint.host(), port: System.get_env("PORT", "4000")}
    |> ElixirAuthGoogle.generate_oauth_url()
  end

  defp get_or_create_user(%{"profile" => profile}) do
    case Repo.get_by(User, email: profile.email) do
      nil -> User.create_user(profile)
      %User{} = user -> {:ok, user}
    end
  end

  defp get_or_create_user(_) do
    {:ok, nil}
  end

  defp get_user_votes(nil), do: []

  defp get_user_votes(%User{} = user) do
    Timeline.list_votes_for_user(user)
  end

  defp get_user_saves(%User{} = user) do
    Timeline.list_saves_for_user(user)
  end

  defp get_user_saves(nil), do: []

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

  defp update_subscriptions(socket, old_clips, new_clips) do
    unsub_list = Enum.filter(old_clips, &(not Enum.member?(new_clips, &1)))
    sub_list = Enum.filter(new_clips, &(not Enum.member?(old_clips, &1)))

    if connected?(socket), do: Timeline.resubscribe(unsub_list, sub_list)
  end

  defp update_saves(saves, clip_id, user_id) do
    case Enum.find(saves, &(clip_id == &1.clip_id)) do
      nil -> add_save(saves, clip_id, user_id)
      save -> remove_save(saves, save)
    end
  end

  defp remove_save(saves, save) do
    case Timeline.delete_save(save) do
      {:ok, _} -> {:ok, Enum.filter(saves, &(&1.id != save.id))}
      {:error, _} = error -> error
    end
  end

  defp add_save(saves, clip_id, user_id) do
    case Timeline.create_save(%{clip_id: clip_id, user_id: user_id}) do
      {:ok, save} -> {:ok, [save | saves]}
      {:error, _} = error -> error
    end
  end
end
