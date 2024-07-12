defmodule MomentumHq.MissionControl.RenderTasksForDay do
  alias MomentumHq.MissionControl
  alias MomentumHq.Telegram

  use MomentumHq.Constants

  def render_and_send_new(user, date) do
    {user_tasks, user_tasks_by_momentums} = user_tasks_grouped_by_momentums(user.id, date)

    render_today_message(
      user.telegram_id,
      length(user_tasks),
      length(Map.keys(user_tasks_by_momentums))
    )
    |> Telegram.send_user_message_async()

    user_tasks_by_momentums
    |> Enum.each(fn {momentum_name, tasks} ->
      render_momentum_with_tasks(user.telegram_id, momentum_name, tasks)
      |> Telegram.send_user_message_async()
    end)
  end

  def rerender_by_task_tg_callback(task, telegram_message_id) do
    user = task.user
    date = task.target_date

    momentum_name = task.momentum.name
    tasks = MissionControl.get_user_tasks_for_a_day(user.id, date, task.momentum_id)

    render_momentum_with_tasks(user.telegram_id, momentum_name, tasks)
    |> Map.put(:message_id, telegram_message_id)
    |> Telegram.update_user_message()
  end

  defp user_tasks_grouped_by_momentums(user_id, date) do
    user_tasks = MissionControl.get_user_tasks_for_a_day(user_id, date)

    user_tasks_by_momentums =
      user_tasks
      |> Enum.group_by(fn task ->
        task.momentum.name
      end)

    {user_tasks, user_tasks_by_momentums}
  end

  defp render_today_message(chat_id, tasks_count, momentums_count) do
    %{
      chat_id: chat_id,
      text: """
      Доброе утро\\! Сегодня у нас в расписании #{tasks_count} задач в #{momentums_count} моментумах\\.

      Легенда:
      ```
      ✅ - Выполнена
      🟡 - Ожидает выполнения
      ❌ - Не выполнена

      - Нажми на кнопку чтобы поменять статус задачи.
      - 🟡 превратится в ❌ завтра утром. 
      ```

      """,
      disable_notification: true
    }
  end

  def render_momentum_with_tasks(chat_id, momentum_name, tasks) do
    momentum_message = "Моментум: `#{Telegram.escape_telegram_markdown(momentum_name)}`"

    tasks_keyboard =
      tasks
      |> Enum.map(fn task ->
        status =
          case task.status do
            :pending -> "🟡"
            :completed -> "✅"
            :failed -> "❌"
          end

        [
          %{
            text: "#{status} #{task.icon} #{task.name}",
            callback_data:
              Jason.encode!(%{
                p: @cycle_task_status,
                id: task.id
              })
          }
        ]
      end)

    %{
      chat_id: chat_id,
      text: momentum_message,
      reply_markup: %{
        inline_keyboard: tasks_keyboard
      },
      disable_notification: true
    }
  end
end
