defmodule PickEmWeb.PickEmLive.Notification do
  use PickEmWeb, :live_view

  def show(socket, message, type \\ :success) when type in [:success, :error] do
    socket
    |> push_event("show-notification", %{})
    |> assign(:notification_message, message)
    |> assign(:notification_type, type)
  end
end
