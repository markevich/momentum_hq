defmodule MomentumHq.Telegram.CallbackData do
  defstruct [
    :callback_data,
    :callback_id,
    :message_id,
    :message_text,
    :chat_id,
    :from
  ]
end
