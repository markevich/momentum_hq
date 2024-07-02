defmodule MomentumHq.Lifecycle.CreateCurrentMomentumWorker do
  use Oban.Worker, queue: :lifecycle, max_attempts: 1

  alias MomentumHq.Blueprinting
  alias MomentumHq.Lifecycle.CurrentDayAndWeek
  alias MomentumHq.MissionControl
  alias MomentumHq.MissionControl.Momentum

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"momentum_blueprint_id" => momentum_blueprint_id}}) do
    momentum_blueprint = Blueprinting.get_momentum_blueprint!(momentum_blueprint_id)
    current_period = CurrentDayAndWeek.relative_to(momentum_blueprint.inserted_at)

    # Fail and alert if we don't receive back {:ok, _result} tuple
    {:ok, _result} =
      case momentum_blueprint.current_momentum do
        # We don't have a current momentum(blueprint recently created)
        nil ->
          create_new_current_momentum(momentum_blueprint, current_period)

        # We have a current momentum, but it's cycle/week_number is in the past.
        %Momentum{cycle_number: cycle_number} when cycle_number != current_period.week_number ->
          create_new_current_momentum(momentum_blueprint, current_period)

        # Otherwise current momentum is for the current cycle. No need to do anything
        _ ->
          {:ok, momentum_blueprint}
      end
  end

  defp create_new_current_momentum(momentum_blueprint, current_day_and_week) do
    attrs = %{
      from: current_day_and_week.start_day_of_week,
      to: current_day_and_week.end_day_of_week,
      cycle_number: current_day_and_week.week_number,
      momentum_blueprint_id: momentum_blueprint.id,
      value_at_start: momentum_blueprint.current_value,
      value_at_end: momentum_blueprint.current_value,
      user_id: momentum_blueprint.user_id
    }

    {:ok, %{momentum_blueprint: updated_momentum_blueprint}} =
      create_new_momentum(attrs)
      |> set_current_momentum(momentum_blueprint)
      |> MomentumHq.Repo.transaction()

    {:ok, updated_momentum_blueprint}
  end

  defp create_new_momentum(attrs) do
    changeset = MissionControl.momentum_changeset(%Momentum{}, attrs)

    Ecto.Multi.new()
    |> Ecto.Multi.insert(:momentum, changeset)
  end

  defp set_current_momentum(transaction, momentum_blueprint) do
    Ecto.Multi.merge(transaction, fn %{momentum: momentum} ->
      changeset =
        Blueprinting.momentum_blueprint_changeset_for_edit(momentum_blueprint, %{
          current_momentum_id: momentum.id
        })

      Ecto.Multi.new()
      |> Ecto.Multi.update(:momentum_blueprint, changeset)
    end)
  end
end
