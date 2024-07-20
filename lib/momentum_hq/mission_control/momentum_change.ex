defmodule MomentumHq.MissionControl.MomentumChange do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias MomentumHq.MissionControl.Momentum
  alias MomentumHq.MissionControl.Task

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "momentum_changes" do
    field :change_amount, :decimal

    belongs_to :momentum, Momentum
    belongs_to :task, Task

    timestamps(type: :utc_datetime)
  end

  def changeset(%MomentumChange{} = momentum, attrs) do
    momentum
    |> cast(attrs, [
      :change_amount,
      :momentum_id,
      :task_id
    ])
    |> validate_required([
      :change_amount,
      :momentum_id,
      :task_id
    ])
  end
end
