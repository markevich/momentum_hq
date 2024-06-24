defmodule MomentumHq.MissionControl.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias MomentumHq.MissionControl.Momentum
  alias MomentumHq.Blueprinting.TaskBlueprint

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "tasks" do
    belongs_to :task_blueprint, TaskBlueprint
    belongs_to :momentum, Momentum

    field :name, :string
    field :affect_type, Ecto.Enum, values: [:low, :medium, :high]
    field :status, Ecto.Enum, values: [:pending, :completed, :failed]
    field :affect_value, :decimal

    timestamps(type: :utc_datetime)
  end

  def changeset(%Task{} = task, attrs) do
    task
    |> cast(attrs, [
      :task_blueprint_id,
      :momentum_id,
      :name,
      :affect_type,
      :status,
      :affect_value
    ])
    |> validate_required([
      :task_blueprint_id,
      :momentum_id,
      :name,
      :affect_type,
      :status,
      :affect_value
    ])
  end
end
