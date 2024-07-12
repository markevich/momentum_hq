defmodule MomentumHq.Pipelines.MissionControl.CycleTaskStatus do
  use MomentumHq.Constants

  alias MomentumHq.MissionControl
  alias MomentumHq.MissionControl.RenderTasksForDay
  alias MomentumHq.Telegram.CallbackData

  def call(%CallbackData{} = callback_data) do
    {:ok, message_id} = Map.fetch(callback_data, :message_id)
    {:ok, task_id} = Map.fetch(callback_data.callback_data, "id")

    MissionControl.cycle_task_status!(task_id)
    |> RenderTasksForDay.rerender_by_task_tg_callback(message_id)
  end
end
