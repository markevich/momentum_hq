defmodule MomentumHq.MissionControl do
  alias MomentumHq.MissionControl.Momentum

  def momentum_changeset(momentum, attrs) do
    Momentum.changeset(momentum, attrs)
  end
end
