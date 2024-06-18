defmodule MomentumWeb.MomentumBlueprintLive.Edit do
  use MomentumWeb, :live_view

  alias Momentum.Blueprinting

  @impl true
  def mount(params, _session, socket) do
    :fitness_center
    :utf8
    momentum_blueprint = Blueprinting.get_momentum_blueprint!(params["id"])

    changeset = Blueprinting.momentum_blueprint_changeset_for_edit(momentum_blueprint)
    {
      :ok,
      socket
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
         |> push_navigate(to: ~p(/momentum_blueprints))}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)
        {:noreply, assign_form(socket, changeset)}
    end
  end


  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    updated_momentum = Ecto.Changeset.apply_changes(changeset)

    assign(socket, :form, to_form(changeset))
    |> assign(:momentum_blueprint, changeset.data)
    |> assign(:task_days_schedules, task_days_schedules(updated_momentum.task_blueprints))
  end

  def task_days_schedules(task_blueprints) do
    Enum.map(1..7, fn index ->
      matched_items = Enum.filter(task_blueprints, fn item ->
        index in item.schedules
      end)

      matched_items
    end)
  end
end
