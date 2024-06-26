defmodule MomentumHq.Lifecycle.CreateTasksForDayWorker do
  alias MomentumHq.Lifecycle
  use Oban.Worker, queue: :lifecycle, max_attempts: 1

  alias Lifecycle.CurrentDayAndWeek
  alias MomentumHq.Blueprinting

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    {:ok, momentum_blueprint_id} = Map.fetch(args, "momentum_blueprint_id")
    {:ok, momentum_id} = Map.fetch(args, "momentum_id")

    momentum_blueprint = Blueprinting.get_momentum_blueprint!(momentum_blueprint_id)
    guard_non_current_momentum!(momentum_blueprint, momentum_id)

    current_momentum = momentum_blueprint.current_momentum
    current_period = CurrentDayAndWeek.relative_to(momentum_blueprint.inserted_at)

    momentum_blueprint.task_blueprints
    |> Enum.filter(fn task_blueprint ->
      current_period.day_of_week in task_blueprint.schedules
    end)
    |> Enum.map(fn task_blueprint ->
      MomentumHq.MissionControl.task_changeset(%MomentumHq.MissionControl.Task{}, %{
        task_blueprint_id: task_blueprint.id,
        momentum_id: current_momentum.id,
        name: task_blueprint.name,
        affect_type: task_blueprint.affect_type,
        status: "pending",
        affect_value: task_blueprint.affect_value,
        # TODO: That's probably wrong. I think we need to pass target date to worker itself
        # and create everything related to that date.
        target_date: current_period.today
      })
    end)
    |> Enum.with_index()
    |> Enum.reduce(Ecto.Multi.new(), fn {task_changeset, index}, multi ->
      multi
      |> Ecto.Multi.insert("task_#{index}", task_changeset)
    end)
    |> MomentumHq.Repo.transaction()
  end

  defp guard_non_current_momentum!(momentum_blueprint, momentum_id) do
    if momentum_blueprint.current_momentum_id != momentum_id do
      raise(
        RuntimeError,
        message:
          "Trying to create tasks for non-current momentum. That should not happen in normal circumstance.",
        momentum_blueprint_id: momentum_blueprint.id,
        momentum_blueprint_current_momentum_id: momentum_blueprint.current_momentum_id,
        incoming_momentum_id: momentum_id
      )
    end
  end
end
