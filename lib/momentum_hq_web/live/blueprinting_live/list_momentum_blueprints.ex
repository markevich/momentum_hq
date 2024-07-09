defmodule MomentumHqWeb.BlueprintingLive.ListMomentumBlueprints do
  use MomentumHqWeb, :live_view

  alias MomentumHq.Blueprinting

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(
       socket,
       :momentum_blueprints,
       Blueprinting.list_momentum_blueprints_by_user(socket.assigns.current_user.id)
     )}
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
