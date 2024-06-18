defmodule Momentum.Repo.Migrations.CreateTaskBlueprints do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE task_blueprint_affect_type AS ENUM ('low', 'medium', 'high')"
    drop_query = "DROP TYPE task_blueprint_affect_type"
    execute(create_query, drop_query)

    create table(:task_blueprints) do
      add :momentum_blueprint_id, references(:momentum_blueprints, on_delete: :restrict),
        null: false

      add :name, :string
      add :icon, :string
      add :color, :string
      add :affect_type, :task_blueprint_affect_type, null: false, default: fragment("'medium'")
      add :week_number, :integer
      add :schedules, {:array, :integer}, null: false, default: fragment("'{}'")
      add :notify_at_hour, :integer
      add :affect_value, :decimal, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:task_blueprints, [:momentum_blueprint_id])
  end
end
