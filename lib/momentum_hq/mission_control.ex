defmodule MomentumHq.MissionControl do
  import Ecto.Query

  alias MomentumHq.Accounts.User
  alias MomentumHq.MissionControl.Momentum
  alias MomentumHq.MissionControl.MomentumChange
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

  def momentum_change_changeset(momentum_change, attrs) do
    MomentumChange.changeset(momentum_change, attrs)
  end

  def cycle_task_status!(task_id) do
    task =
      get_task!(task_id)
      |> Repo.preload([:momentum_change, momentum: [:tasks]])

    {new_status, change_amount} =
      case task.status do
        :pending -> {:completed, task.affect_value}
        :completed -> {:failed, Decimal.negate(task.affect_value)}
        :failed -> {:completed, task.affect_value}
      end

    {:ok, %{task: updated_task}} =
      Ecto.Multi.new()
      |> Ecto.Multi.one(:lock, fn _changes ->
        from(momentum in Momentum,
          where: momentum.id == ^task.momentum_id,
          lock: "FOR UPDATE"
        )
      end)
      |> Ecto.Multi.update(:task, task_changeset(task, %{status: new_status}))
      |> Ecto.Multi.run(:momentum_change, fn _repo, _changes ->
        if task.momentum_change do
          {:ok, task.momentum_change}
        else
          {:ok, %MomentumChange{task_id: task.id, momentum_id: task.momentum_id}}
        end
      end)
      |> Ecto.Multi.insert_or_update(
        :upsert_momentum_change,
        fn %{
             momentum_change: momentum_change
           } ->
          momentum_change_changeset(momentum_change, %{change_amount: change_amount})
        end
      )
      |> Ecto.Multi.one(:sum_of_changes, fn _changes ->
        from(
          c in MomentumChange,
          where: c.momentum_id == ^task.momentum_id,
          select: sum(c.change_amount)
        )
      end)
      |> Ecto.Multi.update(:momentum, fn %{sum_of_changes: sum_of_changes} ->
        final_value = Decimal.add(task.momentum.value_at_start, sum_of_changes)
        momentum_changeset(task.momentum, %{value_at_end: final_value})
      end)
      |> Repo.transaction()

    updated_task
  end
end
