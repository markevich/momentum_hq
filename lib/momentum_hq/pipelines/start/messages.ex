defmodule MomentumHq.Pipelines.Start.Messages do
  alias MomentumHq.Telegram.MessageData

  @output_message """
    Здарова!
  """
  def call(%MessageData{message: "/start"} = message_data) do
    %{}
    |> Map.put(:output_message, @output_message)
    |> MomentumHq.Telegram.SendMessage.call(disable_web_page_preview: true)
  end
end
