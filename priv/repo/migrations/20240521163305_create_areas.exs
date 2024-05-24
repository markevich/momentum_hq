defmodule Momentum.Repo.Migrations.CreateAreas do
  use Ecto.Migration

  def change do
    create table(:areas) do
      add :name, :string

      timestamps(type: :utc_datetime)
    end
  end
end
