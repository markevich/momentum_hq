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

    live_session :authenticated, on_mount: [{MomentumHqWeb.UserAuth, :ensure_authenticated}] do
      live "/blueprinting", BlueprintingLive.ListMomentumBlueprints, :index
      live "/blueprinting/new", BlueprintingLive.NewMomentumBlueprint, :new

      live "/momentums", MomentumLive.ListMomentums, :index

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
    get "/telegram_mini_app/login", UserSessionController, :init_mini_app
    post "/telegram_mini_app/login", UserSessionController, :create_from_mini_app
  end

  scope "/", MomentumHqWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end
