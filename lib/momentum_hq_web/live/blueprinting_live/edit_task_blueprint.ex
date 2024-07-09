defmodule MomentumHqWeb.BlueprintingLive.EditTaskBlueprint do
  use MomentumHqWeb, :live_component

  alias MomentumHq.Blueprinting

  @impl true
  def update(%{task_blueprint: task_blueprint} = assigns, socket) do
    changeset = Blueprinting.task_blueprint_changeset(task_blueprint)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  #  @impl true
  #  def handle_event("validate", %{"task_blueprint" => task_blueprint_params}, socket) do
  #    changeset =
  #      socket.assigns.task_blueprint
  #      |> Blueprinting.task_blueprint_changeset(task_blueprint_params)
  #      |> Map.put(:action, :validate)
  #
  #    {:noreply, assign_form(socket, changeset)}
  #  end

  @impl true
  def handle_event("delete", _params, socket) do
    {:ok, _} = Blueprinting.delete_task_blueprint(socket.assigns.task_blueprint)

    notify_parent({:task_blueprint_saved})

    {:noreply,
     socket
     |> put_flash(:info, "Task blueprint deleted successfully")
     |> push_patch(to: socket.assigns.patch)}
  end

  def handle_event("save", %{"task_blueprint" => task_blueprint_params}, socket) do
    save_task_blueprint(socket, socket.assigns.action, task_blueprint_params)
  end

  defp save_task_blueprint(socket, :edit_task_blueprint, task_blueprint_params) do
    case Blueprinting.update_task_blueprint(socket.assigns.task_blueprint, task_blueprint_params) do
      {:ok, _task_blueprint} ->
        notify_parent({:task_blueprint_saved})

        {:noreply,
         socket
         |> put_flash(:info, "Task blueprint updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_task_blueprint(socket, :new_task_blueprint, task_blueprint_params) do
    params =
      Map.put(
        task_blueprint_params,
        "momentum_blueprint_id",
        socket.assigns.momentum_blueprint_id
      )

    case Blueprinting.create_task_blueprint(params, socket.assigns.user_id) do
      {:ok, _task_blueprint} ->
        notify_parent({:task_blueprint_saved})

        {:noreply,
         socket
         |> put_flash(:info, "Task blueprint created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
