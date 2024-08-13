defmodule MomentumHq.Repo.Migrations.CreateMomentumChanges do
  use Ecto.Migration

  def change do
    create table(:momentum_changes) do
      add :momentum_id, references(:momentums, on_delete: :restrict), null: false
      add :task_id, references(:tasks, on_delete: :delete_all), null: false
      add :change_amount, :decimal, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
