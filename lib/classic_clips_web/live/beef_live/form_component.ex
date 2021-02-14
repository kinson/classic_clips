defmodule ClassicClipsWeb.BeefLive.FormComponent do
  use ClassicClipsWeb, :live_component

  alias ClassicClips.BigBeef

  @impl true
  def update(%{beef: beef} = assigns, socket) do
    changeset = BigBeef.change_beef(beef)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"beef" => beef_params}, socket) do
    changeset =
      socket.assigns.beef
      |> BigBeef.change_beef(beef_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"beef" => beef_params}, socket) do
    save_beef(socket, socket.assigns.action, beef_params)
  end

  defp save_beef(socket, :edit, beef_params) do
    case BigBeef.update_beef(socket.assigns.beef, beef_params) do
      {:ok, _beef} ->
        {:noreply,
         socket
         |> put_flash(:info, "Beef updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_beef(socket, :new, beef_params) do
    case BigBeef.create_beef(beef_params) do
      {:ok, _beef} ->
        {:noreply,
         socket
         |> put_flash(:info, "Beef created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
