defmodule MomentumHq.Blueprinting.MomentumBlueprint do
  use Ecto.Schema
  import Ecto.Changeset

  alias MomentumHq.Users.User
  alias MomentumHq.Blueprinting.TaskBlueprint

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "momentum_blueprints" do
    field :name, :string
    field :generator_type, Ecto.Enum, values: [:weekly, :biweekly, :monthly]
    field :momentums_to_full, :integer
    field :current_value, :decimal

    belongs_to :user, User

    has_many :task_blueprints, TaskBlueprint, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset_for_edit(momentum_blueprint, attrs) do
    momentum_blueprint
    |> cast(attrs, [:generator_type, :momentums_to_full, :current_value, :name])
    |> cast_assoc(:task_blueprints,
      sort_param: :task_blueprints_order,
      drop_param: :task_blueprints_delete,
      with: &TaskBlueprint.changeset/2
    )
    |> validate_required([:generator_type, :momentums_to_full, :current_value, :name])
  end

  def changeset_for_create(momentum_blueprint, attrs) do
    momentum_blueprint
    |> cast(attrs, [:user_id, :name, :generator_type])
    |> validate_required([:user_id, :name, :generator_type])
    |> put_change(:current_value, 50)
    |> put_change(:momentums_to_full, 2)
  end
end
