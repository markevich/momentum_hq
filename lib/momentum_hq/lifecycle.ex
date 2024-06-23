defmodule MomentumHq.Lifecycle do
  import Ecto.Query, warn: false

  alias MomentumHq.Lifecycle.CurrentDayAndWeek
  alias MomentumHq.Blueprinting.MomentumBlueprint
  alias MomentumHq.MissionControl.Momentum

  # TODO: use another *_maybe* mechanism to create new momentum from workers.
  # We need to check existance of current momentum there
  #
  # TODO: Think about asyncronous nature of that operation. Do we want to block users blueprint creation
  # because of the errors with momentums creation?
  def create_new_current_momentum(momentum_blueprint) do
    # FYI: we simply fail with 500 error if current momentum is not created for some reason
    # There is really nothing that user can do with it
    {:ok, %{momentum_blueprint: updated_momentum_blueprint}} =
      create_new_momentum(momentum_blueprint)
      |> set_current_momentum(momentum_blueprint)
      |> MomentumHq.Repo.transaction()

    {:ok, updated_momentum_blueprint}
  end

  defp create_new_momentum(momentum_blueprint) do
    current_day_and_week = CurrentDayAndWeek.relative_to(momentum_blueprint.inserted_at)

    attrs = %{
      from: current_day_and_week.start_day_of_week,
      to: current_day_and_week.end_day_of_week,
      cycle_number: current_day_and_week.week_number,
      momentum_blueprint_id: momentum_blueprint.id,
      value_at_start: momentum_blueprint.current_value,
      value_at_end: momentum_blueprint.current_value,
      user_id: momentum_blueprint.user_id
    }

    changeset = Momentum.changeset(%Momentum{}, attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:momentum, changeset)
  end

  defp set_current_momentum(transaction, momentum_blueprint) do
    Ecto.Multi.merge(transaction, fn %{momentum: momentum} ->
      changeset =
        MomentumBlueprint.changeset_for_edit(momentum_blueprint, %{
          current_momentum_id: momentum.id
        })

      Ecto.Multi.new()
      |> Ecto.Multi.update(:momentum_blueprint, changeset)
    end)
  end
end
