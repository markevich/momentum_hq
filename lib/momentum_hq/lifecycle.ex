defmodule MomentumHq.Lifecycle do
  import Ecto.Query, warn: false

  alias MomentumHq.Lifecycle.CreateCurrentMomentumWorker

  def schedule_current_momentum_creation(momentum_blueprint) do
    %{
      momentum_blueprint_id: momentum_blueprint.id,
      date: Date.to_iso8601(DateTime.to_date(DateTime.utc_now()))
    }
    |> CreateCurrentMomentumWorker.new()
    |> Oban.insert()
  end
end
