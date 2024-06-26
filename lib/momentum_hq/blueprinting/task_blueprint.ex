defmodule MomentumHq.Blueprinting.TaskBlueprint do
  use Ecto.Schema
  import Ecto.Changeset

  alias MomentumHq.Blueprinting.{MomentumBlueprint, TaskBlueprint}

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

  def changeset(%TaskBlueprint{} = task_blueprint, attrs) do
    task_blueprint
    |> cast(attrs, [:name, :schedules, :icon, :color, :momentum_blueprint_id])
    |> validate_required([:name, :schedules, :icon, :color, :momentum_blueprint_id])
    |> update_change(:schedules, &Enum.reject(&1, fn item -> !(item in 1..7) end))
    |> put_change(:affect_value, 5)
  end
end
