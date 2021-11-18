defmodule PickEmWeb.PickEmLive.AccountInfoComponent do
  use PickEmWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-full ml-20 p-4 bg-gray-100 shadow-lg rounded-lg flex flex-row">
     <img class="max-h-20 mr-8 ml-2 my-2" src={Routes.static_path(@socket, "/images/google_logo.png")} alt="Google Sign In" />
     <div class="flex flex-col">
       <div class="flex flex-row mt-2 mb-4">
         <p class="my-0 mr-2 text-white bg-nd-purple text-2xl leading-normal rounded-md px-3 font-open-sans font-light tracking-wide">username</p>
         <%= if @editing_profile do %>
           <p class="my-0 ml-2 underline cursor-pointer" phx-click="cancel" phx-target={@myself}>cancel</p>
         <% else %>
           <p class="my-0 ml-2 underline cursor-pointer" phx-click="edit" phx-target={@myself}>edit</p>
         <% end %>
        </div>
        <%= if @editing_profile do %>
          <.form let={f} for={:user} phx-submit="save" phx-target={@myself}>
            <%= text_input f, :username, value: @user.username, class: "!w-72 block" %>
            <%= submit "Save", class: "text-nd-yellow bg-nd-pink hover:bg-nd-pink focus:bg-nd-pink border-0 mb-0 w-full" %>
          </.form>
        <% else %>
          <p class="m-0 w-72 tracking-wide truncate font-semibold font-open-sans"><%= @user.username %></p>
        <% end %>
       </div>
     </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, :editing_profile, false)}
  end

  @impl true
  def handle_event("edit", _, socket) do
    {:noreply, assign(socket, :editing_profile, true)}
  end

  def handle_event("cancel", _, socket) do
    {:noreply, assign(socket, :editing_profile, false)}
  end

  def handle_event("save", %{"user" => attrs}, socket) do
    case ClassicClips.Timeline.update_user(socket.assigns.user, attrs) do
      {:ok, user} ->
        {:noreply, assign(socket, :user, user) |> assign(:editing_profile, false)}

      _ ->
        {:noreply, socket}
    end
  end
end
