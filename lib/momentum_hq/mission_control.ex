defmodule MomentumHq.MissionControl do
  alias MomentumHq.MissionControl.Momentum
  alias MomentumHq.MissionControl.Task

  def momentum_changeset(momentum, attrs) do
    Momentum.changeset(momentum, attrs)
  end

  def task_changeset(task, attrs) do
    Task.changeset(task, attrs)
  end
end
