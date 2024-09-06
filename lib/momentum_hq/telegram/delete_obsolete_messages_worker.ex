defmodule MomentumHq.Telegram.DeleteObsoleteMessagesWorker do
  use Oban.Worker, queue: :telegram, max_attempts: 1

  alias MomentumHq.Accounts
  alias MomentumHq.MissionControl
  alias MomentumHq.Telegram

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    call(args)
  end

  def call(args) do
    {:ok, user_id} = Map.fetch(args, "user_id")
    {:ok, date} = Map.fetch(args, "date")

    user = Accounts.get_user!(user_id)

    MissionControl.list_obsolete_references(user.id, date)
    |> Enum.map(fn reference ->
      Telegram.delete_user_message(user.telegram_id, reference.telegram_message_id)

      reference.id
    end)
    |> MissionControl.delete_telegram_references()

    :ok
  end
end
