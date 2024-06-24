defmodule MomentumHq.Lifecycle do
  import Ecto.Query, warn: false

  alias MomentumHq.Lifecycle.CreateCurrentMomentumWorker
  alias MomentumHq.Lifecycle.CreateTasksForDayWorker

  def schedule_current_momentum_creation(momentum_blueprint) do
    %{momentum_blueprint_id: momentum_blueprint.id}
    |> CreateCurrentMomentumWorker.new()
    |> Oban.insert()
  end

  def schedule_today_tasks_creation(momentum_blueprint) do
    %{
      momentum_blueprint_id: momentum_blueprint.id,
      momentum_id: momentum_blueprint.current_momentum_id
    }
    |> CreateTasksForDayWorker.new()
    |> Oban.insert()
  end
end
