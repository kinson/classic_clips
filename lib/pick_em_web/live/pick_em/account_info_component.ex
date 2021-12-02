defmodule PickEmWeb.PickEmLive.AccountInfoComponent do
  use PickEmWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div class="w-auto md:w-full ml-10 md:ml-20 py-4 px-8 bg-gray-100 shadow-lg rounded-lg flex flex-row">
     <img class="max-h-24 mr-8 ml-0 my-2" src={Routes.static_path(@socket, "/images/google_logo.png")} alt="Google Sign In" />
     <div class="flex flex-col w-full">
       <div class="flex flex-row my-2">
         <p class="my-0 mr-2 text-nd-pink text-3xl leading-normal font-open-sans font-bold tracking-wide">username</p>
         <%= if @editing_profile do %>
           <p class="my-0 ml-2 underline cursor-pointer" phx-click="cancel" phx-target={@myself}>cancel</p>
         <% else %>
           <p class="my-0 ml-2 underline cursor-pointer" phx-click="edit" phx-target={@myself}>edit</p>
         <% end %>
        </div>
        <%= if @editing_profile do %>
          <.form let={f} for={:user} phx-submit="save" phx-target={@myself} class="mb-0">
            <%= text_input f, :username, value: @user.username, class: "!w-full block font-open-sans font-medium tracking-wide" %>
            <%= submit "Save", class: "text-nd-yellow bg-nd-pink hover:bg-nd-pink focus:bg-nd-pink border-0 mb-0 w-full" %>
          </.form>
        <% else %>
          <p class="m-0 w-72 tracking-wide truncate font-medium font-open-sans tracking-wide"><%= @user.username %></p>
        <% end %>
       </div>
     </div>
    """
  end

  @impl true
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
