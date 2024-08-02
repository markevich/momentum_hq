defmodule MomentumHq.Lifecycle.NewDayStartedWorker do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1

  alias MomentumHq.Lifecycle.CreateNewTasksForUserWorker
  alias MomentumHq.Lifecycle.FailExpiredTasksForUserWorker
  alias MomentumHq.MissionControl
  alias MomentumHq.Telegram

  @impl Oban.Worker
  def perform(_job) do
    MissionControl.list_enabled_active_users()
    |> Enum.each(fn user ->
      iso_date = Date.to_iso8601(DateTime.to_date(DateTime.utc_now()))

      jobs_args = %{user_id: user.id, date: iso_date}

      jobs_args
      |> CreateNewTasksForUserWorker.new()
      |> Oban.insert()

      jobs_args
      |> FailExpiredTasksForUserWorker.new()
      |> Oban.insert()
    end)

    Telegram.send_admin_message_async(%{
      text: Telegram.escape_telegram_markdown("Стартанул новый день для юзеров.")
    })

    :ok
  end
end
