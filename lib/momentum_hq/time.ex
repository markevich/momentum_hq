defmodule MomentumHq.Time do
  @moduledoc """
  Context for time-related operations including timezone handling and time formatting.
  """


  @doc """
  Normalizes timezone string to a standard format.
  """
  def normalize_timezone(timezone) do
    case timezone do
      nil -> nil
      "" -> nil
      "UTC" -> "Etc/UTC"
      "Etc/UTC" -> "Etc/UTC"
      tz when is_binary(tz) -> tz
      _ -> nil
    end
  end

  @doc """
  Converts UTC time to user's timezone.
  """
  def convert_to_user_timezone(utc_time, user) do
    case normalize_timezone(user.timezone) do
      nil -> utc_time
      timezone ->
        try do
          DateTime.shift_zone!(utc_time, timezone)
        rescue
          _ -> utc_time
        end
    end
  end

  @doc """
  Formats DateTime to HH:MM format.
  """
  def format_time(datetime) do
    "#{String.pad_leading(to_string(datetime.hour), 2, "0")}:#{String.pad_leading(to_string(datetime.minute), 2, "0")}"
  end

  @doc """
  Calculates notification datetime based on hour, minute, date, and user timezone.
  """
  def calculate_notification_datetime(hour, minute, date, user_timezone) do
    case {hour, minute} do
      {nil, nil} ->
        nil
      {h, m} when is_integer(h) and is_integer(m) ->
        # Create local time in user's timezone
        local_time = case normalize_timezone(user_timezone) do
          nil -> DateTime.new!(date, Time.new!(h, m, 0), "Etc/UTC")
          "UTC" -> DateTime.new!(date, Time.new!(h, m, 0), "Etc/UTC")
          timezone -> DateTime.new!(date, Time.new!(h, m, 0), timezone)
        end

        # Convert to UTC for storage
        DateTime.shift_zone!(local_time, "Etc/UTC")
      _ ->
        nil
    end
  end

end
