defmodule MomentumWeb.MomentumBlueprintLive.Index do
  use MomentumWeb, :live_view

  alias Momentum.Blueprinting
  alias Momentum.Blueprinting.MomentumBlueprint

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :momentum_blueprints, Blueprinting.list_momentum_blueprints())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit MomentumBlueprint")
    |> assign(:momentum_blueprint, Blueprinting.get_momentum_blueprint!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New MomentumBlueprint")
    |> assign(:momentum_blueprint, %MomentumBlueprint{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing MomentumBlueprints")
    |> assign(:momentum_blueprint, nil)
  end

  @impl true
  def handle_info(
        {MomentumWeb.MomentumBlueprintLive.FormComponent, {:saved, momentum_blueprint}},
        socket
      ) do
    {:noreply, stream_insert(socket, :momentum_blueprints, momentum_blueprint)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    momentum_blueprint = Blueprinting.get_momentum_blueprint!(id)
    {:ok, _} = Blueprinting.delete_momentum_blueprint(momentum_blueprint)

    {:noreply, stream_delete(socket, :momentum_blueprints, momentum_blueprint)}
  end
end
