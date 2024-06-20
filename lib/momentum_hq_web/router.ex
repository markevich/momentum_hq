defmodule MomentumHqWeb.Router do
  use MomentumHqWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MomentumHqWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MomentumHqWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/areas", AreaLive.Index, :index
    live "/areas/new", AreaLive.Index, :new
    live "/areas/:id/edit", AreaLive.Index, :edit

    live "/areas/:id", AreaLive.Show, :show
    live "/areas/:id/show/edit", AreaLive.Show, :edit

    live "/blueprinting", BlueprintingLive.ListMomentumBlueprints, :index
    live "/blueprinting/new", BlueprintingLive.NewMomentumBlueprint, :new
    live "/blueprinting/:momentum_blueprint_id/edit", BlueprintingLive.EditMomentumBlueprint, :edit_momentum_blueprint
    live "/blueprinting/:momentum_blueprint_id/edit/task_blueprints/:task_blueprint_id/edit", BlueprintingLive.EditMomentumBlueprint, :edit_task_blueprint
    live "/blueprinting/:momentum_blueprint_id/edit/task_blueprints/new", BlueprintingLive.EditMomentumBlueprint, :new_task_blueprint
  end

  # Other scopes may use custom stacks.
  # scope "/api", MomentumHqWeb do
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
