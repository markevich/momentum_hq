defmodule MomentumHq.Pipelines.Start.Messages do
  alias MomentumHq.Telegram.MessageData
  alias MomentumHq.Telegram.SendMessage

  @output_message """
    Здарова!
  """
  def call(%MessageData{message: "/start"}) do
    %{}
    |> Map.put(:output_message, @output_message)
    |> SendMessage.call(disable_web_page_preview: true)
  end
end
