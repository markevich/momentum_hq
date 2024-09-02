defmodule MomentumHq.Repo.Migrations.DeleteNameFromMomentums do
  use Ecto.Migration

  def change do
    alter table("momentums") do
      remove :name, :string, null: false
    end
  end
end
