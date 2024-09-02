defmodule MomentumHq.MissionControl do
  import Ecto.Query

  alias MomentumHq.Accounts.User
  alias MomentumHq.Blueprinting
  alias MomentumHq.Blueprinting.MomentumBlueprint
  alias MomentumHq.MissionControl.Momentum
  alias MomentumHq.MissionControl.MomentumChange
  alias MomentumHq.MissionControl.RenderTasksForDay
  alias MomentumHq.MissionControl.Task
  alias MomentumHq.MissionControl.TelegramDayReference

  alias MomentumHq.Repo

  def render_new_day(user, date) do
    RenderTasksForDay.delete_old_messages_and_render_new_day(user, date)
  end

  def fail_expired_user_tasks(user_id, date) do
    {_cnt, ids} =
      from(
        task in Task,
        where: task.user_id == ^user_id,
        where: task.status != :completed,
        where: task.target_date < ^date,
        select: task.id
      )
      |> Repo.update_all(set: [status: :failed, updated_at: DateTime.utc_now()])

    ids
  end

  def list_telegram_references(user_id, date, message_types) do
    from(
      reference in TelegramDayReference,
      where: reference.user_id == ^user_id,
      where: reference.date == ^date,
      where: reference.message_type in ^message_types
    )
    |> Repo.all()
  end

  def list_current_momentums(user_id) do
    from(
      momentum in Momentum,
      join: momentum_blueprint in MomentumBlueprint,
      on: momentum.id == momentum_blueprint.current_momentum_id,
      join: user in assoc(momentum, :user),
      where: user.id == ^user_id,
      order_by: momentum_blueprint.inserted_at
    )
    |> Repo.all()
    |> Repo.preload(tasks: [:momentum_change], momentum_blueprint: [:task_blueprints])
  end

  def delete_telegram_references(ids) do
    from(
      reference in TelegramDayReference,
      where: reference.id in ^ids
    )
    |> Repo.delete_all()
  end

  def get_momentum!(id) do
    Repo.get!(Momentum, id)
  end

  def list_tasks(ids) do
    from(
      task in Task,
      where: task.id in ^ids
    )
    |> Repo.all()
    |> Repo.preload(:momentum)
  end

  def get_task!(task_id) do
    Repo.get!(Task, task_id)
    |> Repo.preload([:user, :momentum])
  end

  def refresh_today_tasks_name(task_blueprint) do
    {_cnt, ids} =
      from(
        task in Task,
        where: task.task_blueprint_id == ^task_blueprint.id,
        where: task.target_date == ^Date.utc_today(),
        select: task.id
      )
      |> Repo.update_all(set: [name: task_blueprint.name, updated_at: DateTime.utc_now()])

    ids
  end

  def maybe_delete_obsolete_today_tasks(task_blueprint) do
    from(
      task in Task,
      join: task_blueprint in assoc(task, :task_blueprint),
      where: task_blueprint.id == ^task_blueprint.id,
      where: task.day_number not in task_blueprint.schedules,
      where: task.target_date == ^Date.utc_today()
    )
    |> Repo.delete_all()
    |> case do
      {cnt_of_deleted, _deleted_tasks} when cnt_of_deleted > 0 ->
        current_momentum = task_blueprint.momentum_blueprint.current_momentum

        Ecto.Multi.new()
        |> recalculate_momentum_value_multi(current_momentum, task_blueprint.momentum_blueprint)
        |> Repo.transaction()

        :ok

      _ ->
        :ok
    end
  end

  def get_user_for_tasks_creation!(id) do
    Repo.get!(User, id)
    |> Repo.preload(momentum_blueprints: [[current_momentum: [:tasks]], :task_blueprints])
  end

  def get_telegram_day_reference(user_id, date, message_type, reference_id) do
    from(
      tg_reference in TelegramDayReference,
      where: tg_reference.user_id == ^user_id,
      where: tg_reference.date == ^date,
      where: tg_reference.message_type == ^message_type,
      where: tg_reference.reference_id == ^reference_id
    )
    |> Repo.one()
    |> Repo.preload(:user)
  end

  def get_user_tasks_for_a_day(user_id, day) do
    from(
      task in Task,
      where: task.user_id == ^user_id,
      where: task.target_date == ^day,
      order_by: task.name
    )
    |> Repo.all()
    |> Repo.preload(momentum: :momentum_blueprint)
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

  def create_telegram_reference!(user_id, date, message_type, reference_id, telegram_message_id) do
    attrs = %{
      user_id: user_id,
      date: date,
      message_type: message_type,
      reference_id: reference_id,
      telegram_message_id: telegram_message_id
    }

    %TelegramDayReference{}
    |> TelegramDayReference.changeset(attrs)
    |> Repo.insert!()
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
      |> Repo.preload([:momentum_change, :task_blueprint, momentum: [:tasks, :momentum_blueprint]])

    {new_status, change_amount} =
      case task.status do
        :pending -> {:completed, task.task_blueprint.affect_value}
        :completed -> {:failed, Decimal.negate(task.task_blueprint.affect_value)}
        :failed -> {:completed, task.task_blueprint.affect_value}
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
      |> recalculate_momentum_value_multi(task.momentum, task.momentum.momentum_blueprint)
      |> Repo.transaction()

    updated_task
  end

  def recalculate_momentum_value_multi(multi, momentum, momentum_blueprint) do
    multi
    |> Ecto.Multi.one(:sum_of_changes, fn _changes ->
      from(
        change in MomentumChange,
        where: change.momentum_id == ^momentum.id,
        select: %{
          pos_sum: sum(fragment("CASE WHEN change_amount < 0 THEN 0 ELSE change_amount END")),
          neg_sum: sum(fragment("CASE WHEN change_amount > 0 THEN 0 ELSE change_amount END"))
        }
      )
    end)
    |> Ecto.Multi.run(:updated_value, fn _repo, %{sum_of_changes: sum_of_changes} ->
      {:ok,
       momentum.value_at_start
       |> Decimal.add(sum_of_changes.neg_sum || 0)
       |> Decimal.max(0)
       |> Decimal.add(sum_of_changes.pos_sum || 0)
       |> Decimal.min(100)}
    end)
    |> Ecto.Multi.update(:momentum, fn %{updated_value: updated_value} ->
      momentum_changeset(momentum, %{value_at_end: updated_value})
    end)
    |> Ecto.Multi.update(:momentum_blueprint, fn %{updated_value: updated_value} ->
      Blueprinting.momentum_blueprint_changeset_for_edit(momentum_blueprint, %{
        current_value: updated_value
      })
    end)
  end
end
