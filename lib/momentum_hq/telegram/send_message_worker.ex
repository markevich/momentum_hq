defmodule MomentumHq.Telegram.SendMessageWorker do
  use Oban.Worker, queue: :telegram, max_attempts: 1

  alias MomentumHq.MissionControl

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

    {:ok, %{"message_id" => message_id}} = call(token, args)

    maybe_insert_reference(args["reference_args"], message_id)
  end

  defp maybe_insert_reference(reference_args, _message_id) when reference_args == nil do
    :ok
  end

  defp maybe_insert_reference(args, telegram_message_id) do
    {:ok, user_id} = Map.fetch(args, "user_id")
    {:ok, date} = Map.fetch(args, "date")
    {:ok, message_type} = Map.fetch(args, "message_type")
    {:ok, reference_id} = Map.fetch(args, "reference_id")

    MissionControl.create_telegram_reference!(
      user_id,
      date,
      message_type,
      reference_id,
      telegram_message_id
    )

    :ok
  end

  @telegram_limit 4096
  defp call(token, args) do
    # https://core.telegram.org/bots/faq#broadcasting-to-users
    :timer.sleep(1000)

    args = Map.put(args, :parse_mode, "MarkdownV2")

    output_message = Map.fetch!(args, "text")
    # Telegram has a limit when sending message of 4096 chars
    if String.length(output_message) < @telegram_limit do
      {:ok, _result} = Telegram.Api.request(token, "sendMessage", args)
    else
      raise "Message Too long for telegram"

      # {left_part, right_part} = {
      #  String.slice(output_message, 0, @telegram_limit),
      #  String.slice(output_message, @telegram_limit..String.length(output_message))
      # }

      # [part_to_move, left_part] =
      #  left_part
      #  |> String.reverse()
      #  |> String.split("\n", parts: 2)

      # left_part = String.reverse(left_part) <> "\n"
      # right_part = String.reverse(part_to_move) <> right_part

      # {:ok, _} = Telegram.Api.request(token, "sendMessage", Keyword.merge(args, text: left_part))
      # {:ok, _} = Telegram.Api.request(token, "sendMessage", Keyword.merge(args, text: right_part))
    end
  end
end
