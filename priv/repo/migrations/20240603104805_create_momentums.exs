defmodule MomentumHq.Repo.Migrations.CreateMomentums do
  use Ecto.Migration

  def change do
    create table(:momentums) do
      add :from, :date, null: false
      add :to, :date, null: false
      add :cycle_number, :integer, null: false
      add :value_at_start, :decimal, null: false
      add :value_at_end, :decimal, null: false
      add :user_id, references(:users, on_delete: :restrict), null: false

      add :momentum_blueprint_id, references(:momentum_blueprints, on_delete: :restrict),
        null: false

      timestamps(type: :utc_datetime)
    end

    create index(:momentums, [:user_id])
    create index(:momentums, [:from, :to])

    create unique_index(:momentums, [:momentum_blueprint_id, :cycle_number])

    alter table(:momentum_blueprints) do
      add :current_momentum_id, references(:momentums), null: true
    end
  end
end
