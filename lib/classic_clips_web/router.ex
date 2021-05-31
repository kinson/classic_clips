defmodule ClassicClipsWeb.Router do
  use ClassicClipsWeb, :router
  import Plug.BasicAuth
  import ClassicClipsWeb.ReqReferer

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ClassicClipsWeb.LayoutView, :root}
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

  scope "/", ClassicClipsWeb do
    pipe_through :browser

    get "/auth/google/callback", GoogleAuthController, :index
    get "/about", AboutController, :index
    get "/beef", RedirectPlug, external: Application.fetch_env!(:classic_clips, :big_beef_url)

    get "/short/:slug", ShortLinkController, :index
    get "/short", ShortLinkController, :index

    live "/classics", ClassicLive.Index, :index

    live "/", ClipLive.Index, :index
    live "/clips", ClipLive.Index, :index
    live "/clips/new", ClipLive.Index, :new
    live "/clips/:id", ClipLive.Show, :show, layout: {ClassicClipsWeb.LayoutView, :show_root}
    live "/clips/:id/edit", ClipLive.Index, :edit
    live "/clips/:id/delete", ClipLive.Index, :delete

    live "/user", UserLive.Show, :show
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
  if Mix.env() in [:dev, :test, :prod] do
    import Phoenix.LiveDashboard.Router

    scope "/admin" do
      pipe_through [:browser, :dash]

      live_dashboard "/dashboard",
        metrics: ClassicClipsWeb.Telemetry,
        ecto_repos: [ClassicClips.Repo]
    end
  end
end
