defmodule MomentumHq.Repo.Migrations.CreateTelegramDayReferences do
  use Ecto.Migration

  def change do
    create table(:telegram_day_references) do
      add :user_id, references(:users, on_delete: :restrict), null: false
      add :date, :date, null: false
      add :message_type, :string, null: false
      add :reference_id, :string
      add :telegram_message_id, :bigint, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
