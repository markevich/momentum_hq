defmodule MomentumHqWeb.BlueprintingLive.EditTaskBlueprint do
  use MomentumHqWeb, :live_component

  alias MomentumHq.Blueprinting
  alias MomentumHq.Lifecycle.CreateNewTasksForUserWorker
  alias MomentumHq.MissionControl

  @impl true
  def update(%{task_blueprint: task_blueprint} = assigns, socket) do
    changeset = Blueprinting.task_blueprint_changeset(task_blueprint)

    days_options =
      case assigns.momentum_blueprint.generator_type do
        :weekly ->
          [{"Пн", 1}, {"Вт", 2}, {"Ср", 3}, {"Чт", 4}, {"Пт", 5}, {"Сб", 6}, {"Вс", 7}]

        :biweekly ->
          [
            {"Пн", 1},
            {"Вт", 2},
            {"Ср", 3},
            {"Чт", 4},
            {"Пт", 5},
            {"Сб", 6},
            {"Вс", 7},
            {"Пн", 8},
            {"Вт", 9},
            {"Ср", 10},
            {"Чт", 11},
            {"Пт", 12},
            {"Сб", 13},
            {"Вс", 14}
          ]
      end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(days_options: days_options)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("delete", _params, socket) do
    :ok = Blueprinting.delete_task_blueprint(socket.assigns.task_blueprint)

    date = Date.utc_today()
    recreate_current_day_for_user(socket.assigns.user_id, date)

    {:noreply,
     socket
     |> put_flash(:info, "Task blueprint deleted successfully")
     |> push_navigate(to: socket.assigns.patch)}
  end

  def handle_event("save", %{"task_blueprint" => task_blueprint_params}, socket) do
    save_task_blueprint(socket, socket.assigns.action, task_blueprint_params)
  end

  defp save_task_blueprint(socket, :edit_task_blueprint, task_blueprint_params) do
    case Blueprinting.update_task_blueprint(socket.assigns.task_blueprint, task_blueprint_params) do
      {:ok, task_blueprint} ->
        MissionControl.refresh_today_tasks_name(task_blueprint)
        MissionControl.maybe_delete_obsolete_today_tasks(task_blueprint)

        notify_parent({:task_blueprint_changed, :edit, task_blueprint})

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
      {:ok, task_blueprint} ->
        notify_parent({:task_blueprint_changed, :create, task_blueprint})

        {:noreply,
         socket
         |> put_flash(:info, "Task blueprint created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp recreate_current_day_for_user(user_id, date) do
    CreateNewTasksForUserWorker.new(%{
      user_id: user_id,
      date: date
    })
    |> Oban.insert()
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
