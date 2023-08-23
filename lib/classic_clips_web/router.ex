defmodule ClassicClipsWeb.Router do
  use ClassicClipsWeb, :router
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

  scope "/", ClassicClipsWeb do
    pipe_through :browser

    get "/auth/google/callback", GoogleAuthController, :index
    get "/about", AboutController, :index
    get "/beef", RedirectPlug, external: Application.compile_env!(:classic_clips, :big_beef_url)

    get "/short/:slug", ShortLinkController, :index
    get "/short", ShortLinkController, :index

    live "/classics", ClassicLive.Index, :index

    live "/", ClipLive.Index, :index
    live "/clips", ClipLive.Index, :index
    live "/clips/new", ClipLive.Index, :new
    # TODO can we wrap all these routes?
    live_session :clip_session, root_layout: {ClassicClipsWeb.LayoutView, :show_root} do
      live "/clips/:id", ClipLive.Show, :show
    end

    live "/clips/:id/edit", ClipLive.Index, :edit
    live "/clips/:id/delete", ClipLive.Index, :delete

    live "/user", UserLive.Show, :show
  end
end
