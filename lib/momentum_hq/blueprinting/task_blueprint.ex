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

    field :notify_at_hour, :integer
    field :notify_at_minute, :integer

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
      :deleted_at,
      :notify_at_hour,
      :notify_at_minute
    ])
    |> validate_required([:name, :schedules, :color, :momentum_blueprint_id, :user_id])
    |> validate_length(:schedules, min: 1)
    |> update_change(:schedules, &Enum.reject(&1, fn item -> !(item in 1..14) end))
    |> validate_notification_time()
    # TODO: Fix that default affect value
    |> put_change(:affect_value, 5)
  end

  defp validate_notification_time(changeset) do
    hour = get_field(changeset, :notify_at_hour)
    minute = get_field(changeset, :notify_at_minute)

    cond do
      is_nil(hour) and is_nil(minute) ->
        changeset

      is_nil(hour) or is_nil(minute) ->
        add_error(
          changeset,
          :notify_at_hour,
          "both hour and minute must be set or both must be nil"
        )

      hour not in 8..23 ->
        add_error(changeset, :notify_at_hour, "must be between 8 and 23")

      minute not in [0, 10, 20, 30, 40, 50] ->
        add_error(changeset, :notify_at_minute, "must be one of: 0, 10, 20, 30, 40, 50")

      true ->
        changeset
    end
  end

end
