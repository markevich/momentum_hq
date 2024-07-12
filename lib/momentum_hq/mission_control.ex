defmodule MomentumHq.MissionControl do
  import Ecto.Query

  alias MomentumHq.Accounts.User
  alias MomentumHq.MissionControl.Momentum
  alias MomentumHq.MissionControl.RenderTasksForDay
  alias MomentumHq.MissionControl.Task

  alias MomentumHq.Repo

  def render_new_day(user, date) do
    RenderTasksForDay.render_and_send_new(user, date)
  end

  def get_task!(task_id) do
    Repo.get!(Task, task_id)
    |> Repo.preload([:user, :momentum])
  end

  def get_user_for_tasks_creation!(id) do
    Repo.get!(User, id)
    |> Repo.preload(momentum_blueprints: [[current_momentum: [:tasks]], :task_blueprints])
  end

  def get_user_tasks_for_a_day(user_id, day) do
    from(
      task in Task,
      where: task.user_id == ^user_id,
      where: task.target_date == ^day,
      order_by: task.name
    )
    |> Repo.all()
    |> Repo.preload(:momentum)
  end

  def get_user_tasks_for_a_day(user_id, day, momentum_id) do
    from(
      task in Task,
      where: task.user_id == ^user_id,
      where: task.target_date == ^day,
      where: task.momentum_id == ^momentum_id,
      order_by: task.name
    )
    |> Repo.all()
    |> Repo.preload(:momentum)
  end

  def list_enabled_active_users do
    from(
      user in User,
      join: task_blueprint in assoc(user, :task_blueprints),
      distinct: user.id
    )
    |> Repo.all()
  end

  def momentum_changeset(momentum, attrs) do
    Momentum.changeset(momentum, attrs)
  end

  def task_changeset(task, attrs) do
    Task.changeset(task, attrs)
  end

  def cycle_task_status!(task_id) do
    task =
      get_task!(task_id)
      |> Repo.preload(momentum: [:tasks])

    new_status =
      case task.status do
        :pending -> :completed
        :completed -> :failed
        :failed -> :completed
      end

    task_changeset(task, %{status: new_status})
    |> Repo.update!()
  end
end
