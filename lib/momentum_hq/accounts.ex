defmodule MomentumHq.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias MomentumHq.Repo

  alias MomentumHq.Accounts.User
  alias MomentumHq.Accounts.UserToken

  def get_user_by_telegram_id(telegram_id) do
    Repo.get_by(User, telegram_id: telegram_id)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def register_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end
end
