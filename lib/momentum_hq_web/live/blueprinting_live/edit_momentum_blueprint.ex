defmodule MomentumHqWeb.BlueprintingLive.EditMomentumBlueprint do
  use MomentumHqWeb, :live_view

  alias MomentumHq.Blueprinting
  alias MomentumHq.Blueprinting.RecalculateTasksWeights
  alias MomentumHqWeb.BlueprintingLive.EditTaskBlueprint
  alias MomentumHq.Lifecycle.CreateNewTasksForUserWorker

  @impl true
  def mount(params, _session, socket) do
    momentum_blueprint =
      Blueprinting.get_momentum_blueprint!(
        params["momentum_blueprint_id"],
        socket.assigns.current_user.id
      )

    changeset = Blueprinting.momentum_blueprint_changeset_for_edit(momentum_blueprint)

    {
      :ok,
      socket
      |> assign_form(changeset)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit_momentum_blueprint, _params) do
    socket
  end

  defp apply_action(socket, :edit_task_blueprint, %{"task_blueprint_id" => id}) do
    socket
    |> assign(:page_title, "Edit task")
    |> assign(:user_id, socket.assigns.current_user.id)
    |> assign(:task_blueprint, Blueprinting.get_task_blueprint!(id))
  end

  defp apply_action(
         socket,
         :new_task_blueprint,
         %{
           "momentum_blueprint_id" => momentum_blueprint_id
         } = params
       ) do
    socket
    |> assign(:page_title, "New Task")
    |> assign(:user_id, socket.assigns.current_user.id)
    |> assign(:task_blueprint, %Blueprinting.TaskBlueprint{
      momentum_blueprint_id: momentum_blueprint_id,
      schedules: [String.to_integer(params["day"])],
      color: :green
    })
  end

  @impl true
  def handle_event("save", %{"momentum_blueprint" => momentum_blueprint_params}, socket) do
    case Blueprinting.update_momentum_blueprint(
           socket.assigns.momentum_blueprint,
           momentum_blueprint_params
         ) do
      {:ok, momentum_blueprint} ->
        changeset = Blueprinting.momentum_blueprint_changeset_for_edit(momentum_blueprint)
        {:noreply, assign_form(socket, changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event(
        "save_and_redirect",
        %{"momentum_blueprint" => momentum_blueprint_params},
        socket
      ) do
    case Blueprinting.update_momentum_blueprint(
           socket.assigns.momentum_blueprint,
           momentum_blueprint_params
         ) do
      {:ok, _momentum_blueprint} ->
        date = Date.utc_today()
        recreate_current_day_for_user(socket.assigns.current_user.id, date)

        {:noreply,
         socket
         |> put_flash(:info, "Momentum blueprint updated successfully")
         |> push_navigate(to: ~p(/blueprinting))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("delete", _params, socket) do
    {:ok, _momentum_blueprint} =
      Blueprinting.delete_momentum_blueprint(socket.assigns.momentum_blueprint)

    date = Date.utc_today()
    recreate_current_day_for_user(socket.assigns.current_user.id, date)

    {:noreply,
     socket
     |> put_flash(:info, "Momentum blueprint deleted successfully")
     |> push_navigate(to: ~p(/blueprinting))}
  end

  @impl true
  def handle_info({EditTaskBlueprint, {:task_blueprint_changed, _event, _task_blueprint}}, socket) do
    date = Date.utc_today()

    recreate_current_day_for_user(socket.assigns.current_user.id, date)

    momentum_blueprint =
      Blueprinting.get_momentum_blueprint!(
        socket.assigns.momentum_blueprint.id,
        socket.assigns.current_user.id
      )

    recalculate_tasks_weights(momentum_blueprint)
    changeset = Blueprinting.momentum_blueprint_changeset_for_edit(momentum_blueprint)

    {:noreply, assign_form(socket, changeset)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    updated_momentum = Ecto.Changeset.apply_changes(changeset)

    assign(socket, :form, to_form(changeset))
    |> assign(:momentum_blueprint, changeset.data)
    |> assign(:task_days_schedules, task_days_schedules(updated_momentum))
  end

  defp recreate_current_day_for_user(user_id, date) do
    CreateNewTasksForUserWorker.new(%{
      user_id: user_id,
      date: date
    })
    |> Oban.insert()
  end

  defp recalculate_tasks_weights(momentum_blueprint) do
    RecalculateTasksWeights.new(%{
      momentum_blueprint_id: momentum_blueprint.id
    })
    |> Oban.insert()
  end

  def task_days_schedules(momentum_blueprint) do
    task_blueprints = momentum_blueprint.task_blueprints

    number_of_days =
      case momentum_blueprint.generator_type do
        :weekly -> 7
        :biweekly -> 14
      end

    Enum.map(1..number_of_days, fn index ->
      matched_items =
        Enum.filter(task_blueprints, fn task_blueprint ->
          !task_blueprint.deleted_at &&
            index in task_blueprint.schedules
        end)

      matched_items
    end)
  end
end
