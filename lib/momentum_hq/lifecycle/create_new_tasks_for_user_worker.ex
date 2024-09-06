defmodule MomentumHq.Lifecycle.CreateNewTasksForUserWorker do
  use Oban.Worker, queue: :telegram, max_attempts: 1
  use MomentumHq.Constants

  alias MomentumHq.Lifecycle.CurrentDayAndWeek
  alias MomentumHq.MissionControl

  @impl Oban.Worker
  def perform(%Job{args: args}) do
    {:ok, user_id} = Map.fetch(args, "user_id")
    {:ok, date} = Map.fetch(args, "date")
    date = Date.from_iso8601!(date)

    user = MissionControl.get_user_for_tasks_creation!(user_id)

    create_tasks_for_date!(user, date)
    MissionControl.render_new_day(user, date)

    :ok
  end

  defp create_tasks_for_date!(user, date) do
    {:ok, _result} =
      user.momentum_blueprints
      |> Enum.reduce(Ecto.Multi.new(), fn momentum_blueprint, multi ->
        prepare_tasks_transaction(momentum_blueprint, date, multi)
      end)
      |> MomentumHq.Repo.transaction()
  end

  defp prepare_tasks_transaction(momentum_blueprint, date, multi) do
    current_period = CurrentDayAndWeek.relative_to(momentum_blueprint.inserted_at, date)

    momentum_blueprint.task_blueprints
    |> Enum.filter(fn task_blueprint ->
      # Task is not deleted
      # Task schedule is for target date
      # Task is not already exists

      !task_blueprint.deleted_at &&
        current_period.day_of_week in task_blueprint.schedules &&
        !Enum.any?(momentum_blueprint.current_momentum.tasks, fn existing_task ->
          existing_task.task_blueprint_id == task_blueprint.id &&
            existing_task.target_date == date
        end)
    end)
    |> Enum.map(fn task_blueprint ->
      MomentumHq.MissionControl.task_changeset(%MomentumHq.MissionControl.Task{}, %{
        task_blueprint_id: task_blueprint.id,
        user_id: momentum_blueprint.user_id,
        momentum_id: momentum_blueprint.current_momentum_id,
        name: task_blueprint.name,
        icon: task_blueprint.icon,
        status: "pending",
        affect_value: task_blueprint.affect_value,
        target_date: date,
        day_number: current_period.day_of_week
      })
    end)
    |> Enum.with_index()
    |> Enum.reduce(multi, fn {task_changeset, index}, multi ->
      multi
      |> Ecto.Multi.insert("task_#{momentum_blueprint.id}.#{index}", task_changeset)
    end)
  end
end
