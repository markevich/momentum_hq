defmodule MomentumHq.Pipelines do
  alias MomentumHq.Telegram.MessageData

  use MomentumHq.Constants

  def call(%MessageData{message: @start_message, chat_id: _chat_id} = message_data) do
    StartMessagesPipeline.call(message_data)
  end
end
