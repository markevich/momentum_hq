defmodule MomentumHq.Pipelines.Start.Messages do
  alias MomentumHq.Telegram
  alias MomentumHq.Telegram.MessageData

  @output_message """
    Здарова!
  """
  def call(%MessageData{message: "/start", current_user: current_user}) do
    %{
      text: @output_message,
      chat_id: current_user.telegram_id
    }
    |> Telegram.send_user_message_async()
  end
end
