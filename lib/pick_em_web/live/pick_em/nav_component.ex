defmodule PickEmWeb.PickEmLive.NavComponent do
  use PickEmWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex flex-row justify-center gap-6 mt-10 mb-16">
      <a href="/" class={get_class("home", @active)}>Home</a>
      <a href="/leaders" class={get_class("leaders", @active)}>Leaders</a>
      <%= if @user do %>
        <a href="/profile" class={get_class("profile", @active)}>Your Profile</a>
      <% end %>
      <a href="/settings" class={get_class("settings", @active)}>Settings</a>
    </div>
    """
  end

  def get_class(page, active) when page == active,
    do: base_class() <> "text-nd-pink active:text-nd-pink hover:text-nd-pink"

  def get_class(_, _),
    do: base_class() <> "text-white active:text-white hover:text-white"

  def base_class(),
    do: "underline my-0 font-open-sans font-bold text-2xl tracking-wider" <> " "
end
