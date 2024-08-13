defmodule MomentumHq.MissionControl.RenderTasksForDay do
  alias MomentumHq.MissionControl
  alias MomentumHq.Telegram

  use MomentumHq.Constants

  def delete_old_messages_and_render_new_day(user, date) do
    MissionControl.list_telegram_references(user.id, date, [
      @message_type_welcome_to_new_day,
      @message_type_momentum
    ])
    |> Enum.map(fn reference ->
      Telegram.delete_user_message(user.telegram_id, reference.telegram_message_id)

      reference.id
    end)
    |> MissionControl.delete_telegram_references()

    render_and_send_new(user, date)
  end

  defp render_and_send_new(user, date) do
    # MissionControl.delete_telegram_references
    {user_tasks, user_tasks_by_momentums} = user_tasks_grouped_by_momentums(user.id, date)

    render_today_message(
      user,
      length(user_tasks),
      length(Map.keys(user_tasks_by_momentums))
    )
    |> Map.put(:reference_args, %{
      user_id: user.id,
      date: date,
      message_type: @message_type_welcome_to_new_day,
      reference_id: nil
    })
    |> Telegram.send_user_message_async_and_save_reference()

    user_tasks_by_momentums
    |> Enum.each(fn {{momentum_id, momentum_name}, tasks} ->
      tasks
      |> render_momentum_with_tasks(user, momentum_name)
      |> Map.put(:reference_args, %{
        user_id: user.id,
        date: date,
        message_type: @message_type_momentum,
        reference_id: momentum_id
      })
      |> Telegram.send_user_message_async_and_save_reference()
    end)
  end

  def rerender_existing_messages(tasks_ids) do
    IO.inspect(tasks_ids)

    MissionControl.list_tasks(tasks_ids)
    |> Enum.group_by(fn task ->
      {task.user_id, task.target_date, task.momentum_id, task.momentum.name}
    end)
    |> Enum.each(fn {{user_id, date, momentum_id, momentum_name}, _tasks} ->
      reference =
        MissionControl.get_telegram_day_reference(
          user_id,
          date,
          @message_type_momentum,
          momentum_id
        )

      # TODO: rerender welcome message?
      # rerender existing momentum tasks message
      MissionControl.get_user_tasks_for_a_day(
        reference.user_id,
        reference.date,
        reference.reference_id
      )
      |> render_momentum_with_tasks(reference.user, momentum_name)
      |> Map.put(:message_id, reference.telegram_message_id)
      |> Telegram.update_user_message()
    end)

    :ok
  end

  defp user_tasks_grouped_by_momentums(user_id, date) do
    user_tasks = MissionControl.get_user_tasks_for_a_day(user_id, date)

    user_tasks_by_momentums =
      user_tasks
      |> Enum.group_by(fn task ->
        {task.momentum.id, task.momentum.name}
      end)

    {user_tasks, user_tasks_by_momentums}
  end

  defp render_today_message(user, tasks_count, momentums_count) do
    message =
      if tasks_count > 0 do
        """
        Привет\\! Сегодня у нас в расписании #{tasks_count} задач в #{momentums_count} моментумах\\.

        Легенда:
        ```
        ✅ - Выполнена
        🟡 - Ожидает выполнения
        ❌ - Не выполнена

        - Нажми на кнопку чтобы поменять статус задачи.
        - 🟡 превратится в ❌ завтра утром. 
        ```

        """
      else
        """
        Привет\\! Сегодня задач нет, отдыхаем 🤙
        """
      end

    %{
      chat_id: user.telegram_id,
      text: message,
      disable_notification: true
    }
  end

  def render_momentum_with_tasks(tasks, user, momentum_name) do
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
            text: "#{status} #{task.name} #{task.icon}",
            callback_data:
              Jason.encode!(%{
                p: @cycle_task_status,
                id: task.id
              })
          }
        ]
      end)

    %{
      chat_id: user.telegram_id,
      text: momentum_message,
      reply_markup: %{
        inline_keyboard: tasks_keyboard
      },
      disable_notification: true
    }
  end
end
