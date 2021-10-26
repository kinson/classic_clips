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

  pipeline :dash do
    plug :basic_auth,
      username: "sam",
      password: Application.fetch_env!(:classic_clips, :dash_pass)
  end

  scope "/", BigBeefWeb do
    pipe_through :browser

    get "/beef", RedirectPlug, to: "/"
    live "/", BeefLive.Index, :index
    live "/history", BeefLive.History, :history
  end

  # Other scopes may use custom stacks.
  # scope "/api", BigBeefWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test, :prod] do
    import Phoenix.LiveDashboard.Router

    scope "/admin" do
      pipe_through [:browser, :dash]
      live_dashboard "/dashboard", metrics: BigBeefWeb.Telemetry, ecto_repos: [ClassicClips.Repo]
    end
  end
end
