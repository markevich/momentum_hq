defmodule MomentumHq.Lifecycle.FindUsersForNotificationWorker do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1

  alias MomentumHq.MissionControl
  alias MomentumHq.Lifecycle.UserTaskNotificationWorker

  @impl Oban.Worker
  def perform(_job) do
    current_time = DateTime.utc_now()

    # Find all users who have tasks that need notifications
    user_ids = MissionControl.get_user_ids_with_notification_tasks(current_time)

    # Create individual jobs for each user
    Enum.each(user_ids, fn user_id ->
      UserTaskNotificationWorker.new(%{"user_id" => user_id})
      |> Oban.insert()
    end)

    :ok
  end
end
