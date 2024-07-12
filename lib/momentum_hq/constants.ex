defmodule MomentumHq.Constants do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      # callbacks
      @cycle_task_status "c_t_s"

      # messages
      @start_message "/start"
    end
  end
end
