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

    Telegram.Api.request(token, "editMessageText", args)
    |> process_result()
  end

  def process_result(result) do
    case result do
      {:ok, result} ->
        {:ok, result}

      {:error,
       "Bad Request: message is not modified: specified new message content and reply markup are exactly the same as a current content and reply markup of the message"} ->
        {:ok, :message_is_the_same}

      {:error, "Forbidden: bot was blocked by the user"} ->
        # TODO: disable user?
        {:ok, :bot_banned}

      {:error, other_reason} ->
        raise RuntimeError, message: other_reason
    end
  end
end
