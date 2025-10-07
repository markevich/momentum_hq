defmodule MomentumHq.Repo.Migrations.AddNotificationFieldsToTaskBlueprints do
  use Ecto.Migration

  def change do
    alter table(:task_blueprints) do
      add :notify_at_hour, :integer
      add :notify_at_minute, :integer
    end
  end
end
