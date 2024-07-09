defmodule MomentumHq.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias MomentumHq.Blueprinting.MomentumBlueprint
  alias MomentumHq.Blueprinting.TaskBlueprint
  alias MomentumHq.MissionControl.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    has_many :tasks, Task
    has_many :task_blueprints, TaskBlueprint
    has_many :momentum_blueprints, MomentumBlueprint

    field :telegram_id, :integer
    field :first_name, :string
    field :photo_url, :string
    field :username, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = task_blueprint, attrs) do
    task_blueprint
    |> cast(attrs, [:telegram_id, :first_name, :photo_url, :username])
    |> validate_required([:telegram_id, :username])
  end
end
