defmodule MomentumHqWeb.AreaLive.Show do
  use MomentumHqWeb, :live_view

  alias MomentumHq.Constructor

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:degrees, calc_angle(50))
     |> assign(:score, 50)
     |> assign(:text, "")
     |> assign(:replay_index, 0)}
  end

  def replay do
    [
      %{
        text: "🥇 Сделал в понедельник",
        type: :positive,
        momentum: 55
      },
      %{
        text: "🥇 Сделал во вторник",
        type: :positive,
        momentum: 60
      },
      %{
        text: "👎 Не cделал в среду",
        type: :negative,
        momentum: 55
      },
      %{
        text: "🥇 Сделал в четверг",
        type: :positive,
        momentum: 70
      },
      %{
        text: "🥇 Сделал в пятницу",
        type: :positive,
        momentum: 65
      },
      %{
        text: "🥇 Сделал в суботу",
        type: :positive,
        momentum: 80
      },
      %{
        text: "👎 Не cделал в воскресенье",
        type: :negative,
        momentum: 60
      },
      %{
        text: "🥇 Сделал в четверг",
        type: :positive,
        momentum: 70
      },
      %{
        text: "🥇 Сделал в пятницу",
        type: :positive,
        momentum: 85
      },
      %{
        text: "🥇 Сделал в суботу",
        type: :positive,
        momentum: 90
      },
      %{
        text: "👎 Не cделал в воскресенье",
        type: :negative,
        momentum: 70
      }
    ]
  end

  @impl true
  def handle_event("replay", _params, socket) do
    Process.send_after(self(), :tick, 1000)

    {:noreply, socket}
  end

  @impl true
  def handle_info(:tick, socket) do
    index = socket.assigns.replay_index

    if index < length(replay()) do
      replay = Enum.at(replay(), index)

      Process.send_after(self(), :tick, 800)

      {
        :noreply,
        socket
        |> assign(:score, replay[:momentum])
        |> assign(:degrees, calc_angle(replay[:momentum]))
        |> assign(:text, replay[:text])
        |> assign(:replay_index, socket.assigns.replay_index + 1)
      }
    else
      {:noreply, assign(socket, :replay_index, 0)}
    end

    # if socket.assigns.timer_status == :running do
    #   Process.send_after(self(), :tick, 1000)
    #   time = Time.add(socket.assigns.time, 1, :second)
    #   {:noreply, assign(socket, :time, time)}
    # else
    #   {:noreply, socket}
    # end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:area, Constructor.get_area!(id))}
  end

  def calc_angle(impact) do
    current_value = impact
    abs_min = 0
    abs_max = 100
    deg_min = -90
    deg_max = 90

    new_deg = (current_value - abs_min) / (abs_max - abs_min) * (deg_max - deg_min) + deg_min
    trunc(new_deg)
  end

  defp page_title(:show), do: "Show Area"
  defp page_title(:edit), do: "Edit Area"
end
