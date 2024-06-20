defmodule MomentumHqWeb.BlueprintingLive.NewMomentumBlueprint do
  use MomentumHqWeb, :live_view

  alias MomentumHq.Blueprinting
  alias MomentumHq.Blueprinting.MomentumBlueprint

  @impl true
  def mount(_params, _session, socket) do
    blueprint_with_defaults = %MomentumBlueprint{generator_type: :weekly}
    changeset = Blueprinting.momentum_blueprint_changeset_for_create(blueprint_with_defaults)

    {:ok, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"momentum_blueprint" => momentum_blueprint_params}, socket) do
    case Blueprinting.create_momentum_blueprint(momentum_blueprint_params) do
      {:ok, momentum_blueprint} ->
        {:noreply,
         socket
         |> push_navigate(to: ~p"/blueprinting/#{momentum_blueprint.id}/edit")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
