defmodule Momentum.Repo.Migrations.CreateMomentumBlueprints do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE momentum_blueprint_generator_type AS ENUM ('weekly', 'biweekly', 'monthly')"
    drop_query = "DROP TYPE momentum_blueprint_generator_type"
    execute(create_query, drop_query)

    create table(:momentum_blueprints) do
      add :generator_type, :momentum_blueprint_generator_type, null: false, default: fragment("'weekly'")
      add :user_id, references(:users, on_delete: :restrict), null: false
      add :momentums_to_full, :integer, null: false
      add :current_value, :decimal, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:momentum_blueprints, [:user_id])
  end
end
