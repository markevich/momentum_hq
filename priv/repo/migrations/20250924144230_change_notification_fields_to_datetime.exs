defmodule MomentumHq.Repo.Migrations.ChangeNotificationFieldsToDatetime do
  use Ecto.Migration

  def up do
    # Remove old notification fields from tasks only
    alter table(:tasks) do
      remove :notify_at_hour, :integer
      remove :notify_at_minute, :integer
    end

    # Add new datetime field to tasks
    alter table(:tasks) do
      add :notify_at, :utc_datetime
    end
  end

  def down do
    # Remove new datetime field from tasks
    alter table(:tasks) do
      remove :notify_at, :utc_datetime
    end

    # Add back old notification fields to tasks
    alter table(:tasks) do
      add :notify_at_hour, :integer
      add :notify_at_minute, :integer
    end
  end
end
