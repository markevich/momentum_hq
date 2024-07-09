defmodule MomentumHq.Telegram.SendMessageWorker do
  use Oban.Worker, queue: :telegram, max_attempts: 1
  alias MomentumHq.Telegram

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    {:ok, _text} = Map.fetch(args, "text")
    {:ok, _chat_id} = Map.fetch(args, "chat_id")
    {:ok, admin} = Map.fetch(args, "admin")

    token =
      if admin do
        Application.fetch_env!(:telegram, :admin_bot_token)
      else
        Application.fetch_env!(:telegram, :client_bot_token)
      end

    call(token, args)
  end

  @telegram_limit 4096
  defp call(token, args) do
    # https://core.telegram.org/bots/faq#broadcasting-to-users
    :timer.sleep(1000)

    args = Map.put(args, :parse_mode, "MarkdownV2")

    output_message = Map.fetch!(args, "text")
    # Telegram has a kimkt when sending message of 4096 chars
    if String.length(output_message) < @telegram_limit do
      Telegram.Api.request(token, "sendMessage", args)
    else
      {left_part, right_part} = {
        String.slice(output_message, 0, @telegram_limit),
        String.slice(output_message, @telegram_limit..String.length(output_message))
      }

      [part_to_move, left_part] =
        left_part
        |> String.reverse()
        |> String.split("\n", parts: 2)

      left_part = String.reverse(left_part) <> "\n"
      right_part = String.reverse(part_to_move) <> right_part

      Telegram.Api.request(token, "sendMessage", Keyword.merge(args, text: left_part))
      Telegram.Api.request(token, "sendMessage", Keyword.merge(args, text: right_part))
    end
  end
end
