defmodule MomentumHq.Telegram.SendMessage do
  def call(
        %{output_message: output_message, current_user: current_user} = payload,
        additional_options
      )
      when not is_nil(current_user) do
    options =
      [
        parse_mode: "Markdown"
      ]
      |> Keyword.merge(additional_options)

    payload
    |> send_message(current_user.telegram_id, output_message, options)
  end

  @telegram_limit 4096
  defp send_message(_payload, chat_id, output_message, _options) do
    token = Application.fetch_env!(:telegram, :clients_bot_token)

    # Telegram has a limit when sending message of 4096 chars
    if String.length(output_message) > @telegram_limit do
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

      Telegram.Api.request(token, "sendMessage", chat_id: chat_id, text: left_part)
      Telegram.Api.request(token, "sendMessage", chat_id: chat_id, text: right_part)
    else
      Telegram.Api.request(token, "sendMessage", chat_id: chat_id, text: output_message)
    end
  end
end
