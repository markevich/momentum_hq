defmodule MomentumHq.Lifecycle.NewDayStarted do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1

  @impl Oban.Worker
  def perform(_job) do

    :ok
  end
end
