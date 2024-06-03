defmodule Momentum.Blueprinting.MomentumBlueprint do
  use Ecto.Schema
  import Ecto.Changeset

  schema "momentum_blueprints" do
    field :generator_type, Ecto.Enum, values: [:weekly, :biweekly]
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(momentum_blueprint, attrs) do
    momentum_blueprint
    |> cast(attrs, [:generator_type])
    |> validate_required([:report_period])
  end
end
