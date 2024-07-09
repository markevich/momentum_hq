defmodule MomentumHq.MissionControl do
  import Ecto.Query, only: [from: 2]

  alias MomentumHq.Accounts.User
  alias MomentumHq.MissionControl.Momentum
  alias MomentumHq.MissionControl.Task
  alias MomentumHq.Repo

  def get_user_for_tasks_creation!(id) do
    Repo.get!(User, id)
    |> Repo.preload(momentum_blueprints: [:task_blueprints])
  end

  def get_user_tasks_for_a_day(user_id, day) do
    from(
      task in Task,
      where: task.user_id == ^user_id,
      where: task.target_date == ^day
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
end
