defmodule MomentumHq.Lifecycle.NewWeekStartedWorker do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1

  alias MomentumHq.Blueprinting
  alias MomentumHq.Lifecycle

  @impl Oban.Worker
  def perform(_job) do
    Blueprinting.list_momentum_blueprints_by_generator_type("weekly")
    |> Enum.each(fn momentum_blueprint ->
      Lifecycle.schedule_current_momentum_creation(momentum_blueprint)
    end)

    :ok
  end
end
