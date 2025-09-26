defmodule MomentumHq.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MomentumHq.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      telegram_id: System.unique_integer([:positive]),
      username: "test_user_#{System.unique_integer()}"
    })
  end

  def user_fixture(attrs \\ %{}) do
    default_attrs = %{
      telegram_id: System.unique_integer([:positive]),
      username: "test_user_#{System.unique_integer()}",
      first_name: "Test User",
      timezone: "UTC"
    }

    attrs = Enum.into(attrs, default_attrs)

    %MomentumHq.Accounts.User{}
    |> MomentumHq.Accounts.User.changeset(attrs)
    |> MomentumHq.Repo.insert!()
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
