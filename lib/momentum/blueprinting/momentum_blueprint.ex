defmodule Momentum.Blueprinting.MomentumBlueprint do
  use Ecto.Schema
  import Ecto.Changeset

  alias Momentum.Users.User
  alias Momentum.Blueprinting.TaskBlueprint


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

  @doc false
  def changeset(momentum_blueprint, attrs) do
    momentum_blueprint
    |> cast(attrs, [:generator_type, :momentums_to_full, :current_value, :name, :user_id])
    |> cast_assoc(:task_blueprints,
      sort_param: :task_blueprints_order,
      drop_param: :task_blueprints_delete,
      with: &TaskBlueprint.changeset/2
    )
    |> validate_required([:generator_type, :momentums_to_full, :current_value,:name, :user_id])
  end
end
