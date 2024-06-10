defmodule Momentum.Repo.Migrations.CreateTasks do
  use Ecto.Migration

  def change do
    create_query =
      "CREATE TYPE task_status_type AS ENUM ('waiting_for_user', 'completed', 'failed')"

    drop_query = "DROP TYPE task_status_type"
    execute(create_query, drop_query)

    create table(:tasks) do
      add :task_blueprint_id, references(:task_blueprints, on_delete: :restrict), null: false
      add :momentum_id, references(:momentums, on_delete: :restrict), null: false
      add :name, :string
      add :affect_type, :task_blueprint_affect_type, null: false
      add :affect_value, :decimal, null: false
      add :status, :task_blueprint_affect_type, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:tasks, [:task_blueprint_id])
    create index(:tasks, [:momentum_id])
    create index(:tasks, [:status])
  end
end
