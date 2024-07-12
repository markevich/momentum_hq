defmodule MomentumHq.Telegram.UpdateMessageWorker do
  use Oban.Worker, queue: :telegram, max_attempts: 1

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    call(args)
  end

  def call(args) do
    {:ok, _message_id} = Map.fetch(args, :message_id)

    token = Application.fetch_env!(:telegram, :client_bot_token)

    args = Map.put(args, :parse_mode, "MarkdownV2")

    {:ok, _} = Telegram.Api.request(token, "editMessageText", args)
  end
end
