defmodule MomentumHq.Lifecycle do
  import Ecto.Query, warn: false

  alias MomentumHq.Blueprinting.MomentumBlueprint

  def generate_new_current_momentum(%MomentumBlueprint{} = momentum_blueprint) do
    IO.inspect(momentum_blueprint)


  end
end
