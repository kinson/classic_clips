defmodule ClassicClipsWeb.ClipLive.FormComponent do
  use ClassicClipsWeb, :live_component

  alias ClassicClips.Timeline

  @impl true
  def update(%{clip: clip} = assigns, socket) do
    changeset = Timeline.change_clip(clip)

    {:ok,
     socket
     |> assign(:tags, get_tags())
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"clip" => clip_params}, socket) do
    changeset =
      socket.assigns.clip
      |> Timeline.change_clip(clip_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"clip" => clip_params}, socket) do
    save_clip(socket, socket.assigns.action, clip_params)
  end

  def handle_event("select-tag-topic", %{"tag" => tag}, socket) do
    topics_tags =
      Enum.map(socket.assigns.tags.topics, fn t ->
        case t.name == tag do
          true -> %{t | selected: not t.selected}
          false -> t
        end
      end)

    new_tags = %{socket.assigns.tags | topics: topics_tags}

    {:noreply, assign(socket, :tags, new_tags)}
  end

  def handle_event("select-tag-crew", %{"tag" => tag}, socket) do
    crew_tags =
      Enum.map(socket.assigns.tags.crew, fn t ->
        case t.name == tag do
          true -> %{t | selected: not t.selected}
          false -> t
        end
      end)

    new_tags = %{socket.assigns.tags | crew: crew_tags}

    {:noreply, assign(socket, :tags, new_tags)}
  end

  defp save_clip(socket, :edit, clip_params) do
    case Timeline.update_clip(socket.assigns.clip, clip_params) do
      {:ok, _clip} ->
        {:noreply,
         socket
         |> put_flash(:info, "Clip updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_clip(socket, :new, clip_params) do
    IO.puts "Hello"
    IO.inspect(clip_params)
    with changeset <- Timeline.change_clip(socket.assigns.clip, clip_params),
         {:ok, changeset} <- validate_yt_url(changeset),
         {:ok, clip} <- Timeline.insert_clip(changeset),
         {:ok, _vote} = Timeline.inc_votes(clip.id, socket.assigns.user) do
      {:noreply,
       socket
       |> put_flash(:info, "Clip created successfully")
       |> push_redirect(to: socket.assigns.return_to)}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  @base_url_for_yt_data "https://www.youtube.com/oembed?url="
  defp get_base_yt_reqeuest_url(clip_url) do
    case String.contains?(clip_url, "?") do
      true -> @base_url_for_yt_data <> clip_url <> "&format=json"
      false -> @base_url_for_yt_data <> clip_url <> "?format=json"
    end
  end

  defp get_clip_data(%{yt_video_url: clip_url}) do
    {:ok, %HTTPoison.Response{body: body}} = get_base_yt_reqeuest_url(clip_url) |> HTTPoison.get()

    Jason.decode(body)
  end

  defp validate_yt_url(%Ecto.Changeset{} = changeset) do
    with {:ok, video_data} <- get_clip_data(changeset.changes),
         true <- is_no_dunks_video?(video_data),
         thumbnail_url <- get_thumbnail_url(video_data) do
      {:ok, Ecto.Changeset.put_change(changeset, :yt_thumbnail_url, thumbnail_url)}
    else
      {:error, _error} ->
        {:ok,
         Ecto.Changeset.add_error(
           changeset,
           :yt_video_url,
           "Must be a valid No Dunks YouTube video url."
         )}

      false ->
        {:ok,
         Ecto.Changeset.add_error(
           changeset,
           :yt_video_url,
           "Must be a No Dunks YouTube video url."
         )}
    end
  end

  defp is_no_dunks_video?(%{"author_name" => "NoDunks Inc"}), do: true

  defp is_no_dunks_video?(%{
         "author_url" => "https://www.youtube.com/channel/UCi6Nwwk1pAp7gYwe3is7Y0g"
       }),
       do: true

  defp is_no_dunks_video?(_), do: false

  defp get_thumbnail_url(%{"thumbnail_url" => thumbnail_url}) do
    String.replace(thumbnail_url, "hqdefault.jpg", "mqdefault.jpg")
  end

  defp get_thumbnail_url(_), do: ""

  defp get_tags() do
    Timeline.list_tags()
    |> Enum.reduce(
      %{topics: [], crew: []},
      fn %ClassicClips.Timeline.Tag{type: type, name: name, id: id}, acc ->
        t = %{selected: false, name: name, id: id}
        case type == "crew" do
          true -> %{acc | crew: [t | acc.crew]}
          false -> %{acc | topics: [t | acc.topics]}
        end
      end
    )
  end
end
