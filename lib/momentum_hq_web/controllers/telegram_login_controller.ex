defmodule MomentumHqWeb.TelegramLoginController do
  use MomentumHqWeb, :controller
  alias MomentumHq.Telegram.SendMessage

  def login(conn, params) do
    send_message(params)
    text(conn, "Надеюсь что-то пришло в телегу")
  end

  defp send_message(params) do
    SendMessage.call(
      %{
        output_message: "Привет из телеграма",
        current_user: %{telegram_chat_id: params["id"]}
      },
      []
    )
  end
end
