defmodule MomentumHqWeb.BlueprintingLive.EditMomentumBlueprint do
  use MomentumHqWeb, :live_view

  alias MomentumHq.Blueprinting

  @impl true
  def mount(params, _session, socket) do
    :fitness_center
    :local_drink
    momentum_blueprint = Blueprinting.get_momentum_blueprint!(params["momentum_blueprint_id"])

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
    |> assign(:task_blueprint, %Blueprinting.TaskBlueprint{
      momentum_blueprint_id: momentum_blueprint_id,
      schedules: [String.to_integer(params["day"])]
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
        IO.inspect(changeset)
        {:noreply, assign_form(socket, changeset)}
    end
  end

  @impl true
  def handle_info(
        {MomentumHqWeb.BlueprintingLive.EditTaskBlueprint, {:task_blueprint_saved}},
        socket
      ) do
    momentum_blueprint =
      Blueprinting.get_momentum_blueprint!(socket.assigns.momentum_blueprint.id)

    changeset = Blueprinting.momentum_blueprint_changeset_for_edit(momentum_blueprint)

    {:noreply, assign_form(socket, changeset)}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    updated_momentum = Ecto.Changeset.apply_changes(changeset)

    assign(socket, :form, to_form(changeset))
    |> assign(:momentum_blueprint, changeset.data)
    |> assign(:task_days_schedules, task_days_schedules(updated_momentum.task_blueprints))
  end

  def task_days_schedules(task_blueprints) do
    Enum.map(1..7, fn index ->
      matched_items =
        Enum.filter(task_blueprints, fn item ->
          index in item.schedules
        end)

      matched_items
    end)
  end
end
