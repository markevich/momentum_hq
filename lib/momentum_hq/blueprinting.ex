defmodule MomentumHq.Blueprinting do
  import Ecto.Query, warn: false
  alias MomentumHq.Lifecycle
  alias MomentumHq.Repo

  alias MomentumHq.Blueprinting.MomentumBlueprint
  alias MomentumHq.Blueprinting.TaskBlueprint

  def list_momentum_blueprints do
    MomentumBlueprint
    |> order_by(asc: :inserted_at)
    |> Repo.all()
    |> Repo.preload(:task_blueprints)
  end

  def list_momentum_blueprints_by_generator_type(generator_type) do
    from(blueprint in MomentumBlueprint,
      where: blueprint.generator_type == ^generator_type
    )
    |> Repo.all()
  end

  def get_momentum_blueprint!(id) do
    Repo.get!(MomentumBlueprint, id)
    |> Repo.preload(:task_blueprints)
    |> Repo.preload(:current_momentum)
  end

  def get_task_blueprint!(id) do
    Repo.get!(TaskBlueprint, id)
  end

  def delete_task_blueprint(%TaskBlueprint{} = task_blueprint) do
    Repo.delete(task_blueprint)
  end

  def create_momentum_blueprint(attrs \\ %{}) do
    create_blueprint_result =
      %MomentumBlueprint{}
      |> MomentumBlueprint.changeset_for_create(attrs)
      |> Repo.insert()

    with {:ok, momentum_blueprint} <- create_blueprint_result do
      Lifecycle.schedule_current_momentum_creation(momentum_blueprint)
    end

    create_blueprint_result
  end

  def update_momentum_blueprint(%MomentumBlueprint{} = momentum_blueprint, attrs) do
    momentum_blueprint
    |> MomentumBlueprint.changeset_for_edit(attrs)
    |> Repo.update()
  end

  def delete_momentum_blueprint(%MomentumBlueprint{} = momentum_blueprint) do
    Repo.delete(momentum_blueprint)
  end

  def momentum_blueprint_changeset_for_edit(momentum_blueprint, attrs \\ %{}) do
    MomentumBlueprint.changeset_for_edit(momentum_blueprint, attrs)
  end

  def momentum_blueprint_changeset_for_create(momentum_blueprint, attrs \\ %{}) do
    MomentumBlueprint.changeset_for_create(momentum_blueprint, attrs)
  end

  def create_task_blueprint(attrs \\ %{}) do
    %TaskBlueprint{}
    |> TaskBlueprint.changeset(attrs)
    |> Repo.insert()
  end

  def update_task_blueprint(%TaskBlueprint{} = task_blueprint, attrs) do
    task_blueprint
    |> TaskBlueprint.changeset(attrs)
    |> Repo.update()
  end

  def task_blueprint_changeset(task_blueprint, attrs \\ %{}) do
    TaskBlueprint.changeset(task_blueprint, attrs)
  end
end
