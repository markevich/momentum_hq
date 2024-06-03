defmodule Momentum.Repo.Migrations.CreateMomentums do
  use Ecto.Migration

  def change do
    create table(:momentums) do
      add :from, :date, null: false
      add :to, :date, null: false
      add :name_override, :string
      add :value_at_start, :decimal, null: false
      add :value_at_end, :decimal, null: false
      add :user_id, references(:users, on_delete: :restrict), null: false
      add :momentum_blueprint_id, references(:momentum_blueprints, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:momentums, [:user_id])
    create index(:momentums, [:momentum_blueprint_id])
    create index(:momentums, [:from, :to])

    create table(:current_momentums) do
      add :user_id, references(:users, on_delete: :restrict), null: false
      add :momentum_blueprint_id, references(:momentum_blueprints, on_delete: :restrict), null: false
      add :momentum_id, references(:momentums), null: false
    end

    create index(:current_momentums, [:user_id])
    create unique_index(:current_momentums, [:user_id, :momentum_blueprint_id, :momentum_id])
  end
end
