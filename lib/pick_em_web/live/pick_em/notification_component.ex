defmodule PickEmWeb.PickEmLive.NotificationComponent do
  use PickEmWeb, :live_component

  alias Phoenix.LiveView.JS

  def render(assigns) do
    assigns =
      assign_new(assigns, :message, fn -> "Hmmm something is not quite right" end)
      |> assign_new(:type, fn -> :success end)

    ~H"""
    <div
      class="w-screen h-max transition-all flex justify-center invisible z-10 h-0 bottom-0 fixed"
      id="notification-container"
    >
      <div
        class={"#{notification_color(@type)} w-max h-fit px-8 py-4 translate-y-0 transition-all text-white rounded-none shadow-notification bottom-0 absolute"}
        phx-click={hide()}
        id="notification"
      >
        <%= @message %>
      </div>
    </div>
    """
  end

  defp hide() do
    JS.dispatch("phx:close-notification")
  end

  defp notification_color(:success), do: "bg-nd-pink"
  defp notification_color(:error), do: "bg-red-500"
  defp notification_color(nil), do: notification_color(:success)

  def show(socket, message, type \\ :success) when type in [:success, :error] do
    socket
    |> push_event("show-notification", %{})
    |> assign(:notification_message, message)
    |> assign(:notification_type, type)
  end
end
