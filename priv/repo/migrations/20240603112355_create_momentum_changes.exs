defmodule Momentum.Repo.Migrations.CreateMomentumChanges do
  use Ecto.Migration

  def change do
    create table(:momentum_changes) do
      add :momentum_id, references(:momentums, on_delete: :restrict), null: false
      add :task_id, references(:tasks, on_delete: :restrict), null: false
      add :old_value, :decimal, null: false
      add :new_value, :decimal, null: false
      add :diff, :decimal, null: false
    end
  end
end
