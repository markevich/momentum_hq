defmodule MomentumHq.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS pgcrypto"

    create table(:users) do
      add :telegram_id, :bigint, null: false
      add :first_name, :string
      add :photo_url, :string
      add :username, :string

      timestamps(type: :utc_datetime)
    end
  end
end
