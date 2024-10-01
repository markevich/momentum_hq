defmodule MomentumHqWeb.MomentumLive.ListMomentums do
  use MomentumHqWeb, :live_view

  alias MomentumHq.Lifecycle.CurrentDayAndWeek
  alias MomentumHq.MissionControl

  @impl true
  def mount(_params, _session, socket) do
    current_momentums =
      socket.assigns.current_user.id
      |> MissionControl.list_current_momentums()
      |> Enum.map(fn momentum ->
        %{
          attrs: momentum,
          meta: momentum_attrs_for_event(momentum)
        }
      end)

    {
      :ok,
      current_momentums
      |> Enum.reduce(socket, fn momentum, updated_socket ->
        updated_socket
        |> push_event("init_momentum_#{momentum.attrs.id}", momentum.meta)
      end)
      |> assign(:current_momentums, current_momentums)
    }
  end

  defp momentum_attrs_for_event(momentum) do
    empty_set =
      case momentum.momentum_blueprint.generator_type do
        :weekly ->
          %{
            1 => [],
            2 => [],
            3 => [],
            4 => [],
            5 => [],
            6 => [],
            7 => []
          }

        :biweekly ->
          %{
            1 => [],
            2 => [],
            3 => [],
            4 => [],
            5 => [],
            6 => [],
            7 => [],
            8 => [],
            9 => [],
            10 => [],
            11 => [],
            12 => [],
            13 => [],
            14 => []
          }
      end

    future_tasks =
      if Date.compare(momentum.to, Date.utc_today()) == :gt do
        today_day_of_week =
          case momentum.momentum_blueprint.generator_type do
            :weekly ->
              CurrentDayAndWeek.weekly_relative_to(
                momentum.momentum_blueprint.inserted_at,
                Date.utc_today()
              ).day_of_cycle

            :biweekly ->
              CurrentDayAndWeek.biweekly_relative_to(
                momentum.momentum_blueprint.inserted_at,
                Date.utc_today()
              ).day_of_cycle
          end

        task_blueprints = momentum.momentum_blueprint.task_blueprints

        task_blueprints
        |> Enum.filter(fn task_blueprint ->
          task_blueprint.deleted_at == nil
        end)
        |> Enum.reduce(empty_set, fn task_blueprint, acc ->
          task_blueprint.schedules
          |> Enum.filter(fn day_number ->
            day_number > today_day_of_week
          end)
          |> Enum.reduce(acc, fn day_number, inner_acc ->
            inner_acc
            |> Map.update!(day_number, fn existing_tasks ->
              virtual_task =
                %{
                  name: task_blueprint.name,
                  status: :pending,
                  day_number: day_number
                }

              [
                virtual_task | existing_tasks
              ]
            end)
          end)
        end)
      else
        %{}
      end

    existing_tasks =
      Enum.group_by(
        momentum.tasks,
        fn task -> task.day_number end,
        fn task ->
          %{
            name: task.name,
            status: task.status,
            day_number: task.day_number
          }
        end
      )

    tasks_by_days =
      empty_set
      |> Map.merge(existing_tasks)
      |> Map.merge(future_tasks, fn _key, left, right -> left ++ right end)
      |> Enum.map(fn {k, v} ->
        {k, Enum.sort_by(v, & &1.status) |> Enum.reverse()}
      end)
      |> Enum.into(%{})

    maximum_tasks_in_a_day =
      tasks_by_days
      |> Enum.map(fn {_day, tasks} -> Enum.count(tasks) end)
      |> Enum.max()

    # https://github.com/elixir-cldr/cldr_dates_times
    %{
      id: momentum.id,
      name: momentum.momentum_blueprint.name,
      generator_type: momentum.momentum_blueprint.generator_type,
      value_at_start: Decimal.round(momentum.value_at_start, 0, :up),
      value_at_end: Decimal.round(momentum.value_at_end, 0, :up),
      maximum_tasks_in_a_day: maximum_tasks_in_a_day,
      tasks_by_days: tasks_by_days,
      counters: counters(tasks_by_days)
    }
  end

  def counters(tasks) do
    tasks
    |> Map.values()
    |> List.flatten()
    |> Enum.group_by(& &1.status)
    |> Enum.map(fn {k, v} ->
      {k, Enum.count(v)}
    end)
    |> Enum.into(%{})
    |> Map.put_new(:completed, 0)
    |> Map.put_new(:failed, 0)
    |> Map.put_new(:pending, 0)
  end
end
