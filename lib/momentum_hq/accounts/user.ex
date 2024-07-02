defmodule MomentumHq.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :telegram_id, :integer
    field :first_name, :string
    field :photo_url, :string
    field :username, :string

    timestamps(type: :utc_datetime)
  end

  def changeset(%__MODULE__{} = task_blueprint, attrs) do
    task_blueprint
    |> cast(attrs, [:telegram_id, :first_name, :photo_url, :username])
    |> validate_required([:telegram_id, :first_name, :photo_url, :username])
  end
end
