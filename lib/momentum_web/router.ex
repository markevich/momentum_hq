defmodule MomentumWeb.Router do
  use MomentumWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MomentumWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers

  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MomentumWeb do
    pipe_through :browser

    get "/", PageController, :home


    live "/areas", AreaLive.Index, :index
    live "/areas/new", AreaLive.Index, :new
    live "/areas/:id/edit", AreaLive.Index, :edit

    live "/areas/:id", AreaLive.Show, :show
    live "/areas/:id/show/edit", AreaLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", MomentumWeb do
  #   pipe_through :api
  # end

  # Enable Swoosh mailbox preview in development
  if Application.compile_env(:momentum, :dev_routes) do

    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end