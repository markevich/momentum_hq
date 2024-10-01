defmodule MomentumHq.Repo.Migrations.CreateTaskBlueprints do
  use Ecto.Migration

  def change do
    create table(:task_blueprints) do
      add :momentum_blueprint_id, references(:momentum_blueprints, on_delete: :restrict),
        null: false

      add :user_id, references(:users, on_delete: :restrict), null: false

      add :name, :string
      add :icon, :string
      add :color, :string
      add :schedules, {:array, :integer}, null: false, default: fragment("'{}'")
      add :affect_value, :decimal, null: false
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:task_blueprints, [:momentum_blueprint_id])
  end
end
