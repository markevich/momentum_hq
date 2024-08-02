defmodule MomentumHq.MissionControl.TelegramDayReference do
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias MomentumHq.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "telegram_day_references" do
    belongs_to :user, User

    field :date, :date
    field :telegram_message_id, :integer
    field :reference_id, :string
    field :message_type, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(%TelegramDayReference{} = reference, attrs) do
    reference
    |> cast(attrs, [
      :user_id,
      :date,
      :telegram_message_id,
      :message_type,
      :reference_id
    ])
    |> validate_required([
      :user_id,
      :date,
      :telegram_message_id,
      :message_type
    ])
  end
end
