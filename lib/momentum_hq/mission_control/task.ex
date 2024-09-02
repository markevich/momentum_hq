defmodule MomentumHq.MissionControl.Task do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias MomentumHq.Accounts.User
  alias MomentumHq.Blueprinting.TaskBlueprint
  alias MomentumHq.MissionControl.Momentum
  alias MomentumHq.MissionControl.MomentumChange
  alias MomentumHq.MissionControl.TelegramTaskReference

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "tasks" do
    belongs_to :task_blueprint, TaskBlueprint
    belongs_to :momentum, Momentum
    belongs_to :user, User
    has_one :momentum_change, MomentumChange
    has_one :telegram_task_reference, TelegramTaskReference

    field :name, :string
    field :icon, :string
    field :status, Ecto.Enum, values: [:pending, :completed, :failed]
    field :affect_value, :decimal
    field :day_number, :integer

    field :target_date, :date

    timestamps(type: :utc_datetime)
  end

  def changeset(%Task{} = task, attrs) do
    task
    |> cast(attrs, [
      :user_id,
      :task_blueprint_id,
      :momentum_id,
      :status,
      :target_date,
      :day_number,
      :affect_value,
      :name
    ])
    |> validate_required([
      :user_id,
      :task_blueprint_id,
      :momentum_id,
      :status,
      :target_date,
      :day_number,
      :affect_value,
      :name
    ])
  end
end
