defmodule MomentumHq.Blueprinting.MomentumBlueprint do
  use Ecto.Schema
  import Ecto.Changeset

  alias MomentumHq.Blueprinting.TaskBlueprint
  alias MomentumHq.MissionControl.Momentum
  alias MomentumHq.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "momentum_blueprints" do
    field :name, :string
    field :generator_type, Ecto.Enum, values: [:weekly, :biweekly, :monthly]
    field :current_value, :decimal

    belongs_to :user, User

    has_many :task_blueprints, TaskBlueprint
    belongs_to :current_momentum, Momentum

    timestamps(type: :utc_datetime)
  end

  def changeset_for_edit(momentum_blueprint, attrs) do
    momentum_blueprint
    |> cast(attrs, [
      :generator_type,
      :current_value,
      :current_momentum_id,
      :name
    ])
    |> validate_required([
      :generator_type,
      :current_value,
      :current_momentum_id,
      :name
    ])
  end

  def changeset_for_create(momentum_blueprint, attrs) do
    momentum_blueprint
    |> cast(attrs, [:user_id, :name, :generator_type])
    |> validate_required([:user_id, :name, :generator_type])
    |> put_change(:current_value, 0)
  end
end
