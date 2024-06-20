defmodule MomentumHq.Blueprinting do
  import Ecto.Query, warn: false
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
  end

  def get_task_blueprint!(id) do
    Repo.get!(TaskBlueprint, id)
  end

  def delete_task_blueprint(%TaskBlueprint{} = task_blueprint) do
    Repo.delete(task_blueprint)
  end

  @doc """
  Creates a momentum_blueprint.

  ## Examples

      iex> create_momentum_blueprint(%{field: value})
      {:ok, %MomentumBlueprint{}}

      iex> create_momentum_blueprint(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_momentum_blueprint(attrs \\ %{}) do
    %MomentumBlueprint{}
    |> MomentumBlueprint.changeset_for_create(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a momentum_blueprint.

  ## Examples

      iex> update_momentum_blueprint(momentum_blueprint, %{field: new_value})
      {:ok, %MomentumBlueprint{}}

      iex> update_momentum_blueprint(momentum_blueprint, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_momentum_blueprint(%MomentumBlueprint{} = momentum_blueprint, attrs) do
    momentum_blueprint
    |> MomentumBlueprint.changeset_for_edit(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a momentum_blueprint.

  ## Examples

      iex> delete_momentum_blueprint(momentum_blueprint)
      {:ok, %MomentumBlueprint{}}

      iex> delete_momentum_blueprint(momentum_blueprint)
      {:error, %Ecto.Changeset{}}

  """
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
