defmodule MomentumHq.Blueprinting.RecalculateTasksWeights do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1

  alias MomentumHq.Blueprinting
  alias MomentumHq.Blueprinting.TaskBlueprint
  alias MomentumHq.Repo

  import Ecto.Query

  @cycles_to_full 2

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"momentum_blueprint_id" => momentum_blueprint_id}}) do
    momentum_blueprint = Blueprinting.get_momentum_blueprint!(momentum_blueprint_id)

    number_of_tasks_in_cycle =
      momentum_blueprint.task_blueprints
      |> Enum.map(fn task_blueprint ->
        Enum.count(task_blueprint.schedules)
      end)
      |> Enum.sum()

    affect_value = 100 / @cycles_to_full / number_of_tasks_in_cycle

    from(
      task_blueprint in TaskBlueprint,
      where: task_blueprint.momentum_blueprint_id == ^momentum_blueprint.id
    )
    |> Repo.update_all(set: [affect_value: affect_value, updated_at: DateTime.utc_now()])

    :ok
  end
end
