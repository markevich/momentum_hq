defmodule MomentumWeb.MomentumBlueprintLive.FormComponent do
  use MomentumWeb, :live_component

  alias Momentum.Blueprinting
  alias Momentum.Blueprinting.MomentumBlueprint

  @impl true
  def update(%{momentum_blueprint: momentum_blueprint} = assigns, socket) do
    changeset = Blueprinting.momentum_blueprint_changeset_for_edit(momentum_blueprint)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
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
    save_momentum_blueprint(socket, socket.assigns.action, momentum_blueprint_params)
  end

  defp save_momentum_blueprint(socket, :edit, momentum_blueprint_params) do
    case Blueprinting.update_momentum_blueprint(
           socket.assigns.momentum_blueprint,
           momentum_blueprint_params
         ) do
      {:ok, momentum_blueprint} ->
        notify_parent({:saved, momentum_blueprint})

        {:noreply,
         socket
         |> put_flash(:info, "Momentum blueprint updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_momentum_blueprint(socket, :new, momentum_blueprint_params) do
    case Blueprinting.create_momentum_blueprint(momentum_blueprint_params) do
      {:ok, momentum_blueprint} ->
        notify_parent({:saved, momentum_blueprint})

        {:noreply,
         socket
         |> put_flash(:info, "Momentum blueprint created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
