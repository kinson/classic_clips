defmodule ClassicClipsWeb.Router do
  use ClassicClipsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ClassicClipsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :beef_web do
    plug :put_root_layout, {ClassicClipsWeb.LayoutView, :beef_root}
    plug :put_layout, {ClassicClipsWeb.LayoutView, :beef_app}
  end

  scope "/", ClassicClipsWeb do
    pipe_through :browser

    get "/auth/google/callback", GoogleAuthController, :index
    get "/about", AboutController, :index

    # live "/", PageLive, :index

    live "/", ClipLive.Index, :index
    live "/clips/new", ClipLive.Index, :new
    live "/clips/:id/edit", ClipLive.Index, :edit
    live "/clips/:id/delete", ClipLive.Index, :delete

    # live "/clips/:id", ClipLive.Show, :show
    # live "/clips/:id/show/edit", ClipLive.Show, :edit

    live "/user", UserLive.Show, :show
  end

  scope "/beef", ClassicClipsWeb do
    pipe_through :browser
    pipe_through :beef_web

    live "/", BeefLive.Index, :index

    get "/previous", BigBeefController, :previous_beef
  end

  # Other scopes may use custom stacks.
  # scope "/api", ClassicClipsWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: ClassicClipsWeb.Telemetry
    end
  end
end
