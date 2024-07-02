defmodule MomentumHqWeb.Router do
  use MomentumHqWeb, :router

  import MomentumHqWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MomentumHqWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MomentumHqWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/blueprinting", BlueprintingLive.ListMomentumBlueprints, :index
    live "/blueprinting/new", BlueprintingLive.NewMomentumBlueprint, :new

    live "/blueprinting/:momentum_blueprint_id/edit",
         BlueprintingLive.EditMomentumBlueprint,
         :edit_momentum_blueprint

    live "/blueprinting/:momentum_blueprint_id/edit/task_blueprints/:task_blueprint_id/edit",
         BlueprintingLive.EditMomentumBlueprint,
         :edit_task_blueprint

    live "/blueprinting/:momentum_blueprint_id/edit/task_blueprints/new",
         BlueprintingLive.EditMomentumBlueprint,
         :new_task_blueprint
  end

  scope "/api", MomentumHqWeb do
    pipe_through :api

    scope "/bot" do
      post "/webhook", BotController, :webhook
    end
  end

  ## Authentication routes

  scope "/", MomentumHqWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", PageController, :home
    get "/users/log_in", UserSessionController, :create
  end

  scope "/", MomentumHqWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end
