defmodule MomentumHq.Repo.Migrations.ModifyDeleteBlueprintBehaviour do
  use Ecto.Migration

  def change do
    alter table("task_blueprints") do
      modify :momentum_blueprint_id, references(:momentum_blueprints, on_delete: :delete_all),
        from: references(:momentum_blueprints, on_delete: :restrict)
    end

    alter table("tasks") do
      modify :task_blueprint_id, references(:task_blueprints, on_delete: :delete_all),
        from: references(:task_blueprints, on_delete: :restrict)
    end

    alter table("momentums") do
      modify :momentum_blueprint_id, references(:momentum_blueprints, on_delete: :delete_all),
        from: references(:momentum_blueprints, on_delete: :restrict)
    end

    alter table("momentum_changes") do
      modify :momentum_id, references(:momentums, on_delete: :delete_all),
        from: references(:momentums, on_delete: :restrict)
    end
  end
end
