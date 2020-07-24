defmodule ChippyWeb.Router do
  use ChippyWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_root_layout, {ChippyWeb.LayoutView, :root}
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChippyWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/profile", PageController, :profile
    post "/profile", PageController, :profile_save
    live "/sprint/new", SprintLive.New
    live "/sprint/:sid", SprintLive.Show
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChippyWeb do
  #   pipe_through :api
  # end
end
