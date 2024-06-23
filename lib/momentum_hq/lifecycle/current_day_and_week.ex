defmodule MomentumHq.Lifecycle.CurrentDayAndWeek do
  # FYI: 1st january of 2024 is monday. Calculate absolute number of weeks passed from that date
  @beginning_of_momentum_era ~D[2024-01-01]

  def absolute do
    today = DateTime.to_date(DateTime.utc_now())
    today_day_of_week = Date.day_of_week(today)

    week_number =
      today
      |> Date.diff(@beginning_of_momentum_era)
      |> div(7)

    %{
      day_of_week: today_day_of_week,
      week_number: week_number
    }
  end

  def relative_to(%DateTime{} = point_of_reference) do
    point_of_reference
    |> DateTime.to_date()
    |> Date.beginning_of_week()
    |> p_relative_to()
  end

  def relative_to(%Date{} = point_of_reference) do
    point_of_reference
    |> Date.beginning_of_week()
    |> p_relative_to()
  end

  defp p_relative_to(%Date{} = point_of_reference) do
    today = DateTime.to_date(DateTime.utc_now())
    today_day_of_week = Date.day_of_week(today)

    week_number =
      today
      |> Date.diff(point_of_reference)
      |> div(7)

    %{
      day_of_week: today_day_of_week,
      week_number: week_number,
      start_day_of_week: Date.beginning_of_week(today),
      end_day_of_week: Date.end_of_week(today)
    }
  end
end
