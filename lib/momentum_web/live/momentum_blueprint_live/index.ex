defmodule MomentumWeb.MomentumBlueprintLive.Index do
  use MomentumWeb, :live_view

  alias Momentum.Blueprinting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :momentum_blueprints, Blueprinting.list_momentum_blueprints())}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {
      :noreply,
      socket
        |> assign(:page_title, "Listing MomentumBlueprints")
        |> assign(:momentum_blueprint, nil)
    }
  end
end
