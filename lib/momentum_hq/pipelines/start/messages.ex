defmodule MomentumHq.Pipelines.Start.Messages do
  alias MomentumHq.Telegram
  alias MomentumHq.Telegram.MessageData

  @output_message """
    Привет! Нажми на кнопку "Приложение" слева внизу."
  """
  def call(%MessageData{message: "/start", current_user: current_user}) do
    %{
      text: Telegram.escape_telegram_markdown(@output_message),
      chat_id: current_user.telegram_id
    }
    |> Telegram.send_user_message_async()
  end
end
