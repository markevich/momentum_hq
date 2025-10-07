defmodule MomentumHq.Lifecycle.UserTaskNotificationWorker do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1, unique: [keys: [:user_id], period: {10, :minutes}]

  alias MomentumHq.MissionControl
  alias MomentumHq.Telegram

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"user_id" => user_id}}) do
    current_time = DateTime.utc_now()

    # Find tasks for this specific user
    tasks_to_notify = MissionControl.get_tasks_for_notification_for_user(user_id, current_time)

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

    # Schedule deletion of the notification message after 1 hour
    schedule_notification_deletion(task.user_id, task.target_date, task.id)
  end

  defp schedule_notification_deletion(user_id, _target_date, _task_id) do
    # Schedule deletion of ALL task notification messages for this user after 1 hour
    MomentumHq.Telegram.DeleteTaskNotificationsWorker.new(%{
      "user_id" => user_id
    }, schedule_in: 60 * 60)  # Schedule for 1 hour from now
    |> Oban.insert()
  end
end
