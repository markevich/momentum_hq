defmodule MomentumHq.MissionControl.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias MomentumHq.Accounts.User
  alias MomentumHq.Blueprinting.TaskBlueprint
  alias MomentumHq.MissionControl.Momentum

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "tasks" do
    belongs_to :task_blueprint, TaskBlueprint
    belongs_to :momentum, Momentum
    belongs_to :user, User

    field :name, :string
    field :icon, :string
    field :affect_type, Ecto.Enum, values: [:low, :medium, :high]
    field :status, Ecto.Enum, values: [:pending, :completed, :failed]
    field :affect_value, :decimal

    field :target_date, :date

    timestamps(type: :utc_datetime)
  end

  def changeset(%Task{} = task, attrs) do
    task
    |> cast(attrs, [
      :user_id,
      :task_blueprint_id,
      :momentum_id,
      :name,
      :affect_type,
      :status,
      :affect_value,
      :target_date
    ])
    |> validate_required([
      :user_id,
      :task_blueprint_id,
      :momentum_id,
      :name,
      :affect_type,
      :status,
      :affect_value,
      :target_date
    ])
  end
end
