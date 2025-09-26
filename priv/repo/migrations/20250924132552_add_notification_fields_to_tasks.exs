defmodule MomentumHq.Repo.Migrations.AddNotificationFieldsToTasks do
  use Ecto.Migration

  def change do
    alter table(:tasks) do
      add :notify_at_hour, :integer
      add :notify_at_minute, :integer
    end
  end
end
