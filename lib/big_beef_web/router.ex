defmodule BigBeefWeb.Router do
  use BigBeefWeb, :router
  import Plug.BasicAuth
  import BigBeefWeb.ReqReferer

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BigBeefWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :record
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", BigBeefWeb do
    pipe_through :browser

    get "/beef", RedirectPlug, to: "/"
    live "/", BeefLive.Index, :index
    live "/history", BeefLive.History, :history
  end
end
