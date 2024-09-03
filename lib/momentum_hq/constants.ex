defmodule MomentumHq.Constants do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      # callbacks
      @cycle_task_status "c_t_s"

      # messages
      @start_message "/start"

      @message_type_welcome_to_new_day "render_welcome_to_new_day"
      @message_type_momentum "render_momentum"
      @message_type_status "momentum_status"
    end
  end
end
