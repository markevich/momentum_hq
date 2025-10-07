defmodule MomentumHq.BlueprintingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `MomentumHq.Blueprinting` context.
  """

  alias MomentumHq.Blueprinting

  def momentum_blueprint_fixture(user, attrs \\ %{}) do
    default_attrs = %{
      name: "Test Momentum",
      generator_type: :weekly,
      user_id: user.id
    }

    attrs = Enum.into(attrs, default_attrs)

    {:ok, momentum_blueprint} = Blueprinting.create_momentum_blueprint(attrs)
    momentum_blueprint
  end

  def task_blueprint_fixture(momentum_blueprint, attrs \\ %{}) do
    default_attrs = %{
      "name" => "Test Task",
      "schedules" => [1, 2, 3],
      "color" => "blue",
      "momentum_blueprint_id" => momentum_blueprint.id,
      "user_id" => momentum_blueprint.user_id
    }

    # Ensure all keys are strings
    string_attrs = for {k, v} <- attrs, into: %{} do
      {to_string(k), v}
    end

    attrs = Enum.into(string_attrs, default_attrs)

    {:ok, task_blueprint} = Blueprinting.create_task_blueprint(attrs, momentum_blueprint.user_id)
    task_blueprint
  end
end
