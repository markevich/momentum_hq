defmodule Momentum.Blueprinting.TaskBlueprint do
  use Ecto.Schema
  import Ecto.Changeset

  alias Momentum.Blueprinting.{TaskBlueprint, MomentumBlueprint}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "task_blueprints" do
    field :name, :string
    field :icon, :string
    field :color, :string
    field :affect_type, Ecto.Enum, values: [:low, :medium, :high]

    field :schedules, {:array, :integer}, default: []

    field :notify_at_hour, :integer
    field :affect_value, :decimal

    belongs_to :momentum_blueprint, MomentumBlueprint

    timestamps(type: :utc_datetime)
  end

  def changeset(task_blueprint = %TaskBlueprint{}, attrs) do
    task_blueprint
    |> cast(attrs, [:name, :schedules, :icon, :color, :momentum_blueprint_id])
    |> validate_required([:name, :schedules, :icon, :color, :momentum_blueprint_id])
    |> put_change(:affect_value, 5)
  end
end
