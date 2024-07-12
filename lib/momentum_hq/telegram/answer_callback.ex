defmodule MomentumHq.Telegram.AnswerCallback do
  def call(callback_id) do
    args = %{
      callback_query_id: callback_id,
      text: "👍"
    }

    token = Application.fetch_env!(:telegram, :client_bot_token)

    try do
      {:ok, _} = Telegram.Api.request(token, "answerCallbackQuery", args)
    rescue
      _e ->
        # Telegram automatically retries failed requests, but callback expires faster than possible retry time limit.
        IO.puts(
          "AnswerCallback errored out. If you see that in tests - that means the request was not stubbed."
        )

        nil
    end
  end
end
