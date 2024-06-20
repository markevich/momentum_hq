defmodule MomentumHq.Lifecycle.NewWeekStarted do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1

  alias MomentumHq.Blueprinting

  @impl Oban.Worker
  def perform(_job) do

    Blueprinting.list_momentum_blueprints_by_generator_type("weekly")
    |> Enum.each(fn momentum_blueprint ->

      IO.inspect(momentum_blueprint)

    end)

    :ok
  end
end
