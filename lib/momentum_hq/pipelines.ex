defmodule MomentumHq.Pipelines do
  alias MomentumHq.Pipelines.MissionControl.CycleTaskStatus
  alias MomentumHq.Pipelines.Start.Messages
  alias MomentumHq.Telegram.CallbackData
  alias MomentumHq.Telegram.MessageData

  use MomentumHq.Constants

  def call(%MessageData{message: @start_message, chat_id: _chat_id} = message_data) do
    Messages.call(message_data)
  end

  def call(
        %CallbackData{callback_data: %{"p" => @cycle_task_status}} =
          callback_data
      ) do
    callback_data
    |> CycleTaskStatus.call()
  end
end
