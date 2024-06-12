defmodule MomentumWeb.MomentumBlueprintV2Live.Edit do
  use MomentumWeb, :live_view

  alias Momentum.Blueprinting

  @impl true
  def mount(params, _session, socket) do
    momentum_blueprint = Blueprinting.get_momentum_blueprint!(params["id"])

    changeset = Blueprinting.momentum_blueprint_changeset_for_edit(momentum_blueprint)
    {
      :ok,
      socket
      |> assign(:momentum_blueprint, momentum_blueprint)
      |> assign_form(changeset)
    }
  end

  @impl true
  def handle_event("validate", %{"momentum_blueprint" => momentum_blueprint_params}, socket) do
    changeset =
      socket.assigns.momentum_blueprint
      |> Blueprinting.momentum_blueprint_changeset_for_edit(momentum_blueprint_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"momentum_blueprint" => momentum_blueprint_params}, socket) do
    case Blueprinting.update_momentum_blueprint(
           socket.assigns.momentum_blueprint,
           momentum_blueprint_params
         ) do
      {:ok, _momentum_blueprint} ->
        {:noreply,
         socket
         |> put_flash(:info, "Momentum blueprint updated successfully")
         |> push_navigate(to: ~p(/momentum_blueprints_v2))}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
