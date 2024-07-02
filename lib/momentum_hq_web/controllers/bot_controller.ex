defmodule MomentumHqWeb.BotController do
  use MomentumHqWeb, :controller

  alias MomentumHq.Pipelines
  alias MomentumHq.Telegram.MessageData

  def webhook(conn, %{"message" => message}) do
    try do
      input_message = get_in(message, "text")
      chat_id = get_in(message, ["chat", "id"])
      reply_to_message = get_in(message, ["reply_to_message", "text"])

      %MessageData{message: input_message, chat_id: chat_id, reply_to_message: reply_to_message}
      |> Pipelines.call()
    rescue
      _e ->
        nil
        # log_exception(e, __STACKTRACE__, %{input_message: input_message})

        # message = "Случилось что-то страшное, и я не смог обработать запрос."

        # SendMessage.call(%{
        # output_message: message,
        # chat_id: chat_id
        # })
    end

    json(conn, %{})
  end

  def webhook(conn, _params) do
    json(conn, %{})
  end
end
