defmodule Momentum.Blueprinting.TaskBlueprint do
  use Ecto.Schema
  import Ecto.Changeset

  alias Momentum.Blueprinting.TaskBlueprint
  alias Momentum.Blueprinting.MomentumBlueprint


  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "task_blueprints" do
    field :affect_type, Ecto.Enum, values: [:low, :medium, :high]
    field :week_number, :integer

    field :week_day, {:array, Ecto.Enum},
      values: [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

    field :notify_at_hour, :integer
    field :affect_value, :decimal

    belongs_to :momentum_blueprint, MomentumBlueprint

    timestamps(type: :utc_datetime)
  end

  def changeset(task_blueprint = %TaskBlueprint{}, attrs) do
    task_blueprint
    |> cast(attrs, [:week_day, :affect_value])
    |> validate_required([:week_day, :affect_value])
  end
end
