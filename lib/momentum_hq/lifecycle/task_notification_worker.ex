defmodule MomentumHq.Lifecycle.TaskNotificationWorker do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1

  alias MomentumHq.MissionControl
  alias MomentumHq.Telegram

  @impl Oban.Worker
  def perform(_job) do
    current_time = DateTime.utc_now()

    # Find all tasks that need notifications using MissionControl context
    tasks_to_notify = MissionControl.get_tasks_for_notification(current_time)

    # Send notifications and clear notification fields
    Enum.each(tasks_to_notify, &send_notification_and_clear/1)

    :ok
  end

  defp send_notification_and_clear(task) do
    # Send Telegram notification
    send_task_notification(task)

    # Clear notification fields through MissionControl context
    MissionControl.clear_task_notification_fields(task)
  end

  defp send_task_notification(task) do
    message = MissionControl.build_task_notification_message(task)

    Telegram.send_user_message_async_and_save_reference(%{
      chat_id: task.user.telegram_id,
      text: message,
      reference_args: %{
        user_id: task.user_id,
        date: Date.to_string(task.target_date),
        message_type: "task_notification",
        reference_id: task.id
      }
    })
  end
end
