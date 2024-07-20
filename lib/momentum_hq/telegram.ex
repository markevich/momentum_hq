defmodule MomentumHq.Telegram do
  alias MomentumHq.Telegram.SendMessageWorker
  alias MomentumHq.Telegram.UpdateMessageWorker

  @special_chars [
    "\\",
    "_",
    "*",
    "[",
    "]",
    "(",
    ")",
    "~",
    "`",
    ">",
    "<",
    "&",
    "#",
    "+",
    "-",
    "=",
    "|",
    "{",
    "}",
    ".",
    "!"
  ]
  def escape_telegram_markdown(text) do
    @special_chars
    |> Enum.reduce(text, fn pattern, acc ->
      String.replace(acc, pattern, "\\#{pattern}")
    end)
  end

  def send_user_message_async(args) when is_map(args) do
    args
    |> Map.put(:admin, false)
    |> send_message_async()
  end

  def update_user_message(args) when is_map(args) do
    UpdateMessageWorker.call(args)
  end

  def send_admin_message_async(args) when is_map(args) do
    admin_chat_id = Application.fetch_env!(:telegram, :admin_chat_id)

    args
    |> Map.put(:chat_id, admin_chat_id)
    |> Map.put(:admin, true)
    |> send_message_async()
  end

  defp send_message_async(args) do
    {:ok, _text} = Map.fetch(args, :text)
    {:ok, _chat_id} = Map.fetch(args, :chat_id)

    args
    |> SendMessageWorker.new()
    |> Oban.insert()
  end
end
