defmodule ClassicClipsWeb.ClipLive.FormComponent do
  use ClassicClipsWeb, :live_component

  alias ClassicClips.Timeline

  @impl true
  def update(%{clip: clip} = assigns, socket) do
    changeset = Timeline.change_clip(clip)

    {:ok,
     socket
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
    case Timeline.create_clip(clip_params, socket.assigns.user) do
      {:ok, _clip} ->
        {:noreply,
         socket
         |> put_flash(:info, "Clip created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
