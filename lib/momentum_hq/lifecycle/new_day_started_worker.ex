defmodule MomentumHq.Lifecycle.NewDayStartedWorker do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1

  alias MomentumHq.Lifecycle.StartNewDayForUserWorker
  alias MomentumHq.MissionControl
  alias MomentumHq.Telegram

  @impl Oban.Worker
  def perform(_job) do
    MissionControl.list_enabled_active_users()
    |> Enum.each(fn user ->
      %{user_id: user.id, date: Date.to_iso8601(DateTime.to_date(DateTime.utc_now()))}
      |> StartNewDayForUserWorker.new()
      |> Oban.insert()
    end)

    Telegram.send_admin_message_async(%{
      text: Telegram.escape_telegram_markdown("Стартанул новый день для юзеров.")
    })

    :ok
  end
end
