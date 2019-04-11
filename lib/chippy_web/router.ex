defmodule ChippyWeb.Router do
  use ChippyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ChippyWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/new", PageController, :new
    get "/s/:sid", PageController, :sprint
  end

  # Other scopes may use custom stacks.
  # scope "/api", ChippyWeb do
  #   pipe_through :api
  # end
end
