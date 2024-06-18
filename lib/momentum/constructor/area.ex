defmodule Momentum.Constructor.Area do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "areas" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(area, attrs) do
    area
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
