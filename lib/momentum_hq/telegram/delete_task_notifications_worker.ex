defmodule MomentumHq.Telegram.DeleteTaskNotificationsWorker do
  use Oban.Worker, queue: :telegram, max_attempts: 1

  alias MomentumHq.Accounts
  alias MomentumHq.MissionControl
  alias MomentumHq.Telegram

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    {:ok, user_id} = Map.fetch(args, "user_id")

    user = Accounts.get_user!(user_id)

    # Find ALL task notification messages for this user (regardless of date)
    MissionControl.list_task_notification_references(user.id)
    |> Enum.map(fn reference ->
      # Delete the message from Telegram
      Telegram.delete_user_message(user.telegram_id, reference.telegram_message_id)

      # Return the reference ID for database cleanup
      reference.id
    end)
    |> MissionControl.delete_telegram_references()

    :ok
  end
end
