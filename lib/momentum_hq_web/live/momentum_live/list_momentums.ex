defmodule MomentumHqWeb.MomentumLive.ListMomentums do
  use MomentumHqWeb, :live_view

  alias MomentumHq.MissionControl

  @impl true
  def mount(_params, _session, socket) do
    current_momentums = MissionControl.list_current_momentums(socket.assigns.current_user.id)

    {
      :ok,
      current_momentums
      |> Enum.reduce(socket, fn momentum, updated_socket ->
        updated_socket
        |> push_event("init_momentum_#{momentum.id}", momentum_attrs_for_event(momentum))
      end)
      |> assign(:current_momentums, current_momentums)
    }
  end

  defp momentum_attrs_for_event(momentum) do
    %{
      id: momentum.id,
      name: momentum.name,
      value_at_start: momentum.value_at_start,
      value_at_end: momentum.value_at_end,
      momentum_changes:
        Enum.map(momentum.momentum_changes, fn change ->
          %{
            task_name: change.task.name,
            change_amount: change.change_amount
          }
        end)
    }
  end
end
