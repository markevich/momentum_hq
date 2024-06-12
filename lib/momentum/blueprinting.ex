defmodule Momentum.Blueprinting do
  import Ecto.Query, warn: false
  alias Momentum.Repo

  alias Momentum.Blueprinting.MomentumBlueprint

  @doc """
  Returns the list of momentum_blueprints.

  ## Examples

      iex> list_momentum_blueprints()
      [%MomentumBlueprint{}, ...]

  """
  def list_momentum_blueprints do
    MomentumBlueprint
    |> order_by(asc: :inserted_at)
    |> Repo.all()
    |> Repo.preload(:task_blueprints)
  end

  @doc """
  Gets a single momentum_blueprint.

  Raises `Ecto.NoResultsError` if the MomentumBlueprint does not exist.

  ## Examples

      iex> get_momentum_blueprint!(123)
      %MomentumBlueprint{}

      iex> get_momentum_blueprint!(456)
      ** (Ecto.NoResultsError)

  """
  def get_momentum_blueprint!(id) do
    Repo.get!(MomentumBlueprint, id)
    |> Repo.preload(:task_blueprints)
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
    |> MomentumBlueprint.changeset(attrs)
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
    |> MomentumBlueprint.changeset(attrs)
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

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking momentum_blueprint changes.

  ## Examples

      iex> change_momentum_blueprint(momentum_blueprint)
      %Ecto.Changeset{data: %MomentumBlueprint{}}

  """
  def change_momentum_blueprint(%MomentumBlueprint{} = momentum_blueprint, attrs \\ %{}) do
    MomentumBlueprint.changeset(momentum_blueprint, attrs)
  end
end
