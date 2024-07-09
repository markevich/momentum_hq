defmodule MomentumHq.MissionControl.Momentum do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias MomentumHq.Users.User
  alias MomentumHq.Blueprinting.MomentumBlueprint

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "momentums" do
    field :from, :date
    field :to, :date
    field :name, :string
    field :cycle_number, :integer
    field :value_at_start, :decimal
    field :value_at_end, :decimal

    belongs_to :user, User
    belongs_to :momentum_blueprint, MomentumBlueprint

    timestamps(type: :utc_datetime)
  end

  def changeset(%Momentum{} = momentum, attrs) do
    momentum
    |> cast(attrs, [
      :from,
      :to,
      :name,
      :cycle_number,
      :value_at_start,
      :value_at_end,
      :momentum_blueprint_id,
      :user_id
    ])
    |> validate_required([
      :from,
      :to,
      :name,
      :cycle_number,
      :value_at_start,
      :value_at_end,
      :momentum_blueprint_id,
      :user_id
    ])
    |> unique_constraint([:momentum_id, :cycle_number])
  end
end
