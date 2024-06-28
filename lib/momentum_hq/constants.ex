defmodule MomentumHq.Constants do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      # callbacks
      @start_message "/start"
    end
  end
end
