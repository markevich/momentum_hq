defmodule MomentumHq.Pipelines do
  alias MomentumHq.Pipelines.Start.Messages
  alias MomentumHq.Telegram.MessageData

  use MomentumHq.Constants

  def call(%MessageData{message: @start_message, chat_id: _chat_id} = message_data) do
    Messages.call(message_data)
  end
end
