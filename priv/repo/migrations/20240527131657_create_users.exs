defmodule Momentum.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto"

    create table(:users) do
      add :telegram_id, :bigint

      timestamps(type: :utc_datetime)
    end
  end
end
