defmodule MomentumHqWeb.UserSessionController do
  use MomentumHqWeb, :controller

  alias MomentumHq.Accounts
  alias MomentumHq.Telegram
  alias MomentumHqWeb.UserAuth

  def create(conn, params) do
    {:ok, auth_data} = validate_telegram_auth_data(params)

    auth_data =
      auth_data
      |> Map.put("telegram_id", auth_data["id"])
      |> Map.delete("id")

    if user = Accounts.get_user_by_telegram_id(auth_data["telegram_id"]) do
      # Accounts.maybe_update_user_after_auth(user, auth_data)
      UserAuth.log_in_user(conn, user)
    else
      {:ok, user} = Accounts.register_user(auth_data)

      Telegram.send_user_message_async(%{
        chat_id: user.telegram_id,
        text: "Привет, @#{user.username}! Поздравляю с успешной регистрацией в Momentum!"
      })

      UserAuth.log_in_user(conn, user, params)
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  def validate_telegram_auth_data(auth_data) do
    {hash, auth_data} = Map.pop(auth_data, "hash")

    token = Application.fetch_env!(:telegram, :clients_bot_token)
    bot_token_hash = :crypto.hash(:sha256, token)

    check_string =
      auth_data
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map_join("\n", fn {k, v} -> "#{k}=#{v}" end)

    auth_data_hash =
      :crypto.mac(:hmac, :sha256, bot_token_hash, check_string)
      |> Base.encode16(case: :lower)

    if auth_data_hash == hash do
      {:ok, auth_data}
    else
      :error
    end
  end
end
