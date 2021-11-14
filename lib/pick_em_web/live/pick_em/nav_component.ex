defmodule PickEmWeb.PickEmLive.NavComponent do
  use PickEmWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex flex-row justify-center mt-10 mb-16">
      <a href="/" class={get_class("home", @active)}>Home</a>
      <a href="/leaders" class={get_class("leaders", @active)}>Leader Board</a>
      <a href="/profile" class={get_class("profile", @active)}>Your Profile</a>
    </div>
    """
  end

  def get_class(page, active) when page == active do
   "text-nd-pink underline  my-0 mx-2 font-open-sans font-bold text-3xl tracking-wider"
  end

  def get_class(_, _) do
    "text-white underline my-0 mx-2 font-open-sans font-bold text-3xl tracking-wider"
  end
end
