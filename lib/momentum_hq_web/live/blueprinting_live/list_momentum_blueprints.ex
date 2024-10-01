defmodule MomentumHqWeb.BlueprintingLive.ListMomentumBlueprints do
  use MomentumHqWeb, :live_view

  alias MomentumHq.Blueprinting

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(
       socket,
       :momentum_blueprints,
       blueprints(socket.assigns.current_user.id)
     )}
  end

  defp blueprints(user_id) do
    Blueprinting.list_momentum_blueprints_by_user(user_id)
    |> Enum.map(fn momentum_blueprint ->
      mapped_schedules =
        momentum_blueprint.task_blueprints
        |> schedules(momentum_blueprint)

      %{
        id: momentum_blueprint.id,
        name: momentum_blueprint.name,
        generator_type: momentum_blueprint.generator_type,
        schedules: mapped_schedules,
        stats: calculate_stats(mapped_schedules)
      }
    end)
  end

  defp schedules(task_blueprints, momentum_blueprint) do
    case momentum_blueprint.generator_type do
      :weekly ->
        Enum.reduce(1..7, %{}, fn index, acc ->
          schedules_count_reducer(task_blueprints, index, acc)
        end)

      :biweekly ->
        Enum.reduce(1..14, %{}, fn index, acc ->
          schedules_count_reducer(task_blueprints, index, acc)
        end)
    end
  end

  defp schedules_count_reducer(task_blueprints, index, acc) do
    count =
      task_blueprints
      |> Enum.count(fn task_blueprint ->
        !task_blueprint.deleted_at &&
          index in task_blueprint.schedules
      end)

    acc
    |> Map.put(index, count)
  end

  defp calculate_stats(mapped_schedules) do
    stats =
      mapped_schedules
      |> Enum.reduce({0, 0}, fn {_day, count}, {busy_days, all_tasks_count} ->
        if count > 0 do
          {busy_days + 1, all_tasks_count + count}
        else
          {busy_days, all_tasks_count}
        end
      end)

    number_of_days = ngettext("One day", "%{count} days", elem(stats, 0))
    number_of_tasks = ngettext("One task", "%{count} tasks", elem(stats, 1))
    "#{number_of_days}. #{number_of_tasks}."
  end
end
