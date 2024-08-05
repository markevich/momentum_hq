defmodule MomentumHqWeb.BlueprintingLive.EditMomentumBlueprint do
  alias MomentumHq.Lifecycle.CreateNewTasksForUserWorker
  use MomentumHqWeb, :live_view

  alias MomentumHq.Blueprinting
  alias MomentumHq.MissionControl
  alias MomentumHq.MissionControl.RenderTasksForDay
  alias MomentumHqWeb.BlueprintingLive.EditTaskBlueprint

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
        {:noreply,
         socket
         |> put_flash(:info, "Momentum blueprint updated successfully")
         |> push_navigate(to: ~p(/blueprinting))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_info({EditTaskBlueprint, {:task_blueprint_changed, event, task_blueprint}}, socket) do
    date = Date.to_iso8601(DateTime.to_date(DateTime.utc_now()))

    case event do
      :create ->
        recreate_current_day_for_user(socket.assigns.current_user.id, date)

      :edit ->
        MissionControl.refresh_today_tasks_name(task_blueprint)
        |> RenderTasksForDay.rerender_existing_messages()

      :delete ->
        recreate_current_day_for_user(socket.assigns.current_user.id, date)
    end

    momentum_blueprint =
      Blueprinting.get_momentum_blueprint!(
        socket.assigns.momentum_blueprint.id,
        socket.assigns.current_user.id
      )

    changeset = Blueprinting.momentum_blueprint_changeset_for_edit(momentum_blueprint)

    {:noreply, assign_form(socket, changeset)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    updated_momentum = Ecto.Changeset.apply_changes(changeset)

    assign(socket, :form, to_form(changeset))
    |> assign(:momentum_blueprint, changeset.data)
    |> assign(:task_days_schedules, task_days_schedules(updated_momentum.task_blueprints))
  end

  defp recreate_current_day_for_user(user_id, date) do
    CreateNewTasksForUserWorker.new(%{
      user_id: user_id,
      date: date
    })
    |> Oban.insert()
  end

  def task_days_schedules(task_blueprints) do
    Enum.map(1..7, fn index ->
      matched_items =
        Enum.filter(task_blueprints, fn task_blueprint ->
          !task_blueprint.deleted_at &&
            index in task_blueprint.schedules
        end)

      matched_items
    end)
  end
end
