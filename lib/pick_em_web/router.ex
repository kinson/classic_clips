defmodule PickEmWeb.Router do
  use PickEmWeb, :router
  import PickEmWeb.ReqReferer

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PickEmWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :record
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PickEmWeb do
    pipe_through :browser
    get "/auth/google/callback", GoogleAuthController, :index
    get "/auth/twitter/callback", TwitterAuthController, :index
    post "/auth/logout", GoogleAuthController, :logout
    post "/theme", ThemeController, :create

    live "/", PickEmLive.Index, :index
    live "/leaders", PickEmLive.Leaders, :leaders
    live "/profile", PickEmLive.Profile, :profile
    live "/settings", PickEmLive.Settings, :settings
    live "/secaucus", PickEmLive.Secaucus, :secaucus
    live "/matchup-hero", PickEmLive.MatchupHero, :matchup_hero
  end

  if Mix.env() == :dev do
    scope "/mail/dev" do
      pipe_through [:browser]

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
