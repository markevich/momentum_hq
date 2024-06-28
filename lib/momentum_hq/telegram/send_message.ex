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
    |> send_message(current_user.telegram_chat_id, output_message, options)
  end

  @telegram_limit 4096
  defp send_message(payload, chat_id, output_message, options) do
    Application.fetch_env!(:telegram, :clients_bot_token)
    |> Telegram.Api.request("send_message", chat_id: chat_id, text: output_message)

    # https://3abb-188-169-198-6.ngrok-free.app/telegram_login?id=117137841&first_name=Slava&username=mr_slava1&photo_url=https%3A%2F%2Ft.me%2Fi%2Fuserpic%2F320%2FiyL5Wc1aBDoPOc47eG6K6MTjWswDi51bRXM1dcDsszk.jpg&auth_date=1719587912&hash=2285cf0ab41a629e8927fc07229479007a5ccc54a11634443eb022a70c072155
    # Telegram has a limit when sending message of 4096 chars
    # if String.length(output_message) > @telegram_limit do
    #   {left_part, right_part} = {
    #     String.slice(output_message, 0, @telegram_limit),
    #     String.slice(output_message, @telegram_limit..String.length(output_message))
    #   }

    #   [part_to_move, left_part] =
    #     left_part
    #     |> String.reverse()
    #     |> String.split("\n", parts: 2)

    #   left_part = String.reverse(left_part) <> "\n"
    #   right_part = String.reverse(part_to_move) <> right_part

    #   default_markdown_option = [parse_mode: "Markdown"]
    #   Nadia.send_message(chat_id, left_part, default_markdown_option) |> process_result(payload)
    #   Nadia.send_message(chat_id, right_part, options) |> process_result(payload)
    # else
    #   Nadia.send_message(chat_id, output_message, options)
    #   |> process_result(payload)
    # end
  end
end
