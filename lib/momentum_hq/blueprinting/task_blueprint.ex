defmodule MomentumHq.Blueprinting.TaskBlueprint do
  use Ecto.Schema
  import Ecto.Changeset

  alias MomentumHq.Accounts.User
  alias MomentumHq.Blueprinting.{MomentumBlueprint, TaskBlueprint}
  alias MomentumHq.MissionControl.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "task_blueprints" do
    field :name, :string
    field :icon, :string
    field :color, :string

    field :schedules, {:array, :integer}

    field :affect_value, :decimal
    field :deleted_at, :utc_datetime

    belongs_to :user, User
    belongs_to :momentum_blueprint, MomentumBlueprint
    has_many :tasks, Task

    timestamps(type: :utc_datetime)
  end

  def changeset(%TaskBlueprint{} = task_blueprint, attrs) do
    task_blueprint
    |> cast(attrs, [
      :name,
      :schedules,
      :icon,
      :color,
      :momentum_blueprint_id,
      :user_id,
      :deleted_at
    ])
    |> validate_required([:name, :schedules, :color, :momentum_blueprint_id, :user_id])
    |> validate_length(:schedules, min: 1)
    |> update_change(:schedules, &Enum.reject(&1, fn item -> !(item in 1..14) end))
    # TODO: Fix that default affect value
    |> put_change(:affect_value, 5)
  end
end
