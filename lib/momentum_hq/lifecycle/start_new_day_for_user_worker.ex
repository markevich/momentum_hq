defmodule MomentumHq.Lifecycle.StartNewDayForUserWorker do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1

  alias MomentumHq.Lifecycle.CurrentDayAndWeek
  alias MomentumHq.MissionControl
  alias MomentumHq.Telegram

  @impl Oban.Worker
  def perform(%Job{args: args}) do
    {:ok, user_id} = Map.fetch(args, "user_id")
    {:ok, date} = Map.fetch(args, "date")
    date = Date.from_iso8601!(date)

    user = MissionControl.get_user_for_tasks_creation!(user_id)
    create_tasks_for_date!(user, date)
    send_tasks_to_telegram(user, date)
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
      current_period.day_of_week in task_blueprint.schedules
    end)
    |> Enum.map(fn task_blueprint ->
      MomentumHq.MissionControl.task_changeset(%MomentumHq.MissionControl.Task{}, %{
        task_blueprint_id: task_blueprint.id,
        user_id: momentum_blueprint.user_id,
        momentum_id: momentum_blueprint.current_momentum_id,
        name: task_blueprint.name,
        icon: task_blueprint.icon,
        affect_type: task_blueprint.affect_type,
        status: "pending",
        affect_value: task_blueprint.affect_value,
        target_date: date
      })
    end)
    |> Enum.with_index()
    |> Enum.reduce(multi, fn {task_changeset, index}, multi ->
      multi
      |> Ecto.Multi.insert("task_#{momentum_blueprint.id}.#{index}", task_changeset)
    end)
  end

  defp send_tasks_to_telegram(user, date) do
    Telegram.send_user_message_async(%{
      chat_id: user.telegram_id,
      text: Telegram.escape_telegram_markdown("Доброе утро! Задачи на сегодня:"),
      disable_notification: true
    })

    MissionControl.get_user_tasks_for_a_day(user.id, date)
    |> Enum.group_by(fn task ->
      task.momentum.name
    end)
    |> Enum.each(fn {momentum_name, tasks} ->
      %{
        chat_id: user.telegram_id,
        text: "Моментум: `#{Telegram.escape_telegram_markdown(momentum_name)}`",
        disable_notification: true
      }
      |> Telegram.send_user_message_async()

      tasks
      |> Enum.with_index()
      |> Enum.each(fn {task, index} ->
        %{
          chat_id: user.telegram_id,
          text: "#{task.icon} #{task.name}",
          disable_notification: true
        }
        |> Telegram.send_user_message_async()
      end)
    end)
  end
end
