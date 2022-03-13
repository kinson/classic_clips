defmodule PickEmWeb.PickEmLive.NotificationComponent do
  use PickEmWeb, :live_component

  alias Phoenix.LiveView.JS

  def render(assigns) do
    assigns =
      assign_new(assigns, :message, fn -> "Hmmm something is not quite right" end)
      |> assign_new(:type, fn -> :success end)

    ~H"""
    <div
      class="w-full absolute translate-y-0 transition-all flex justify-center align-center invisible z-10 h-0 overflow-hidden bottom-0"
      id="notification"
    >
      <div
        class={"#{notification_color(@type)} px-8 py-4 text-white rounded-none shadow-lg flex"}
        phx-click={hide()}
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
