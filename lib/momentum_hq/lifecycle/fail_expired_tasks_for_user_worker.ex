defmodule MomentumHq.Lifecycle.FailExpiredTasksForUserWorker do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1
  use MomentumHq.Constants

  alias MomentumHq.MissionControl
  alias MomentumHq.MissionControl.RenderTasksForDay

  @impl Oban.Worker
  def perform(%Job{args: args}) do
    {:ok, user_id} = Map.fetch(args, "user_id")
    {:ok, date} = Map.fetch(args, "date")
    date = Date.from_iso8601!(date)

    MissionControl.fail_expired_user_tasks(user_id, date)
    |> RenderTasksForDay.rerender_existing_messages()

    :ok
  end
end
