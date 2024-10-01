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
      # TODO: minor
      # Accounts.maybe_update_user_after_auth(user, auth_data)
      UserAuth.log_in_user(conn, user)
    else
      {:ok, user} = Accounts.register_user(auth_data)

      Telegram.send_user_message_async(%{
        chat_id: user.telegram_id,
        text:
          Telegram.escape_telegram_markdown(
            "Привет, @#{user.username}! Поздравляю с успешной регистрацией в Momentum!"
          )
      })

      UserAuth.log_in_user(conn, user, params)
    end
  end

  def create_from_mini_app(conn, %{"json_init_data" => query} = params) do
    {:ok, auth_data} = validate_telegram_mini_app_auti_data(query)

    auth_data =
      auth_data
      |> Map.put("telegram_id", auth_data["id"])
      |> Map.delete("id")
      |> Map.put("timezone", params["timezone"])

    if user = Accounts.get_user_by_telegram_id(auth_data["telegram_id"]) do
      # TODO: minor
      # Accounts.maybe_update_user_after_auth(user, auth_data)
      UserAuth.log_in_user(conn, user)
    else
      {:ok, user} = Accounts.register_user(auth_data)

      Telegram.send_user_message_async(%{
        chat_id: user.telegram_id,
        text:
          Telegram.escape_telegram_markdown(
            "Привет, @#{user.username}! Поздравляю с успешной регистрацией в Momentum!"
          )
      })

      UserAuth.log_in_user(conn, user, params)
    end
  end

  def init_mini_app(conn, _params) do
    conn
    |> put_root_layout(false)
    |> render(:login_from_miniapp, layout: false)
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end

  def validate_telegram_mini_app_auti_data(auth_data_unsigned) do
    {hash, auth_data} =
      auth_data_unsigned
      |> URI.decode_query()
      |> Map.pop("hash")

    token = Application.fetch_env!(:telegram, :client_bot_token)
    secret = :crypto.mac(:hmac, :sha256, "WebAppData", token)

    calculated_hash =
      auth_data
      |> Enum.sort_by(fn {key, _} -> key end)
      |> Enum.map(fn {key, value} -> "#{key}=#{value}" end)
      |> Enum.join("\n")
      |> then(&:crypto.mac(:hmac, :sha256, secret, &1))
      |> Base.encode16(case: :lower)

    if calculated_hash == hash do
      user_data = Jason.decode!(auth_data["user"])

      {:ok, user_data}
    else
      {:error, :tg_auth_failed}
    end
  end

  def validate_telegram_auth_data(auth_data) do
    {hash, auth_data} = Map.pop(auth_data, "hash")

    token = Application.fetch_env!(:telegram, :client_bot_token)
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
