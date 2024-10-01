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

  def weekly_relative_to(%DateTime{} = start_date, target_date) do
    start_date
    |> DateTime.to_date()
    |> Date.beginning_of_week()
    |> p_weekly_relative_to(target_date)
  end

  def weekly_relative_to(%Date{} = start_date, target_date) do
    start_date
    |> Date.beginning_of_week()
    |> p_weekly_relative_to(target_date)
  end

  defp p_weekly_relative_to(%Date{} = start_date, target_date) do
    target_day_of_cycle = Date.day_of_week(target_date)

    cycle_number =
      target_date
      |> Date.diff(start_date)
      |> div(7)

    %{
      target_date: target_date,
      day_of_cycle: target_day_of_cycle,
      cycle_number: cycle_number,
      start_day_of_cycle: Date.beginning_of_week(target_date),
      end_day_of_cycle: Date.end_of_week(target_date)
    }
  end

  def biweekly_relative_to(%DateTime{} = start_date, target_date) do
    start_date
    |> DateTime.to_date()
    |> Date.beginning_of_week()
    |> p_biweekly_relative_to(target_date)
  end

  def biweekly_relative_to(%Date{} = start_date, target_date) do
    start_date
    |> Date.beginning_of_week()
    |> p_biweekly_relative_to(target_date)
  end

  defp p_biweekly_relative_to(%Date{} = start_date, target_date) do
    week_number =
      target_date
      |> Date.diff(start_date)
      |> div(7)

    cycle_number =
      target_date
      |> Date.diff(start_date)
      |> div(14)

    cycle_week_number = rem(week_number, 2)

    target_day_of_cycle =
      if cycle_week_number == 1 do
        Date.day_of_week(target_date)
      else
        7 + Date.day_of_week(target_date)
      end

    %{
      target_date: target_date,
      day_of_cycle: target_day_of_cycle,
      cycle_number: cycle_number,
      cycle_week_number: cycle_week_number,
      start_day_of_cycle: Date.beginning_of_week(target_date),
      end_day_of_cycle: Date.end_of_week(target_date)
    }
  end
end
