defmodule MomentumHq.MissionControl.TaskTest do
  use MomentumHqDataCase, async: true

  alias MomentumHq.MissionControl.Task

  import MomentumHq.AccountsFixtures
  import MomentumHq.BlueprintingFixtures

  describe "notification time validation" do
    setup do
      user = user_fixture()
      momentum_blueprint = momentum_blueprint_fixture(user)
      task_blueprint = task_blueprint_fixture(momentum_blueprint)
      momentum = momentum_fixture(momentum_blueprint)

      %{user: user, momentum: momentum, task_blueprint: task_blueprint}
    end

    test "validates notification time when both hour and minute are provided", %{
      user: user,
      momentum: momentum,
      task_blueprint: task_blueprint
    } do
      attrs = %{
        user_id: user.id,
        task_blueprint_id: task_blueprint.id,
        momentum_id: momentum.id,
        status: :pending,
        target_date: Date.utc_today(),
        day_number: 1,
        affect_value: Decimal.new("5"),
        name: "Test Task",
        icon: "📋",
        notify_at_hour: 10,
        notify_at_minute: 30
      }

      changeset = Task.changeset(%Task{}, attrs)
      assert changeset.valid?
    end

    test "validates notification time when both are nil", %{
      user: user,
      momentum: momentum,
      task_blueprint: task_blueprint
    } do
      attrs = %{
        user_id: user.id,
        task_blueprint_id: task_blueprint.id,
        momentum_id: momentum.id,
        status: :pending,
        target_date: Date.utc_today(),
        day_number: 1,
        affect_value: Decimal.new("5"),
        name: "Test Task",
        icon: "📋",
        notify_at_hour: nil,
        notify_at_minute: nil
      }

      changeset = Task.changeset(%Task{}, attrs)
      assert changeset.valid?
    end

    test "rejects when only hour is provided", %{
      user: user,
      momentum: momentum,
      task_blueprint: task_blueprint
    } do
      attrs = %{
        user_id: user.id,
        task_blueprint_id: task_blueprint.id,
        momentum_id: momentum.id,
        status: :pending,
        target_date: Date.utc_today(),
        day_number: 1,
        affect_value: Decimal.new("5"),
        name: "Test Task",
        icon: "📋",
        notify_at_hour: 10,
        notify_at_minute: nil
      }

      changeset = Task.changeset(%Task{}, attrs)
      refute changeset.valid?

      assert "both hour and minute must be set or both must be nil" in errors_on(changeset).notify_at_hour
    end

    test "rejects when only minute is provided", %{
      user: user,
      momentum: momentum,
      task_blueprint: task_blueprint
    } do
      attrs = %{
        user_id: user.id,
        task_blueprint_id: task_blueprint.id,
        momentum_id: momentum.id,
        status: :pending,
        target_date: Date.utc_today(),
        day_number: 1,
        affect_value: Decimal.new("5"),
        name: "Test Task",
        icon: "📋",
        notify_at_hour: nil,
        notify_at_minute: 30
      }

      changeset = Task.changeset(%Task{}, attrs)
      refute changeset.valid?

      assert "both hour and minute must be set or both must be nil" in errors_on(changeset).notify_at_hour
    end

    test "rejects invalid hour values", %{
      user: user,
      momentum: momentum,
      task_blueprint: task_blueprint
    } do
      attrs = %{
        user_id: user.id,
        task_blueprint_id: task_blueprint.id,
        momentum_id: momentum.id,
        status: :pending,
        target_date: Date.utc_today(),
        day_number: 1,
        affect_value: Decimal.new("5"),
        name: "Test Task",
        icon: "📋",
        notify_at_hour: 25,
        notify_at_minute: 30
      }

      changeset = Task.changeset(%Task{}, attrs)
      refute changeset.valid?
      assert "must be between 8 and 23" in errors_on(changeset).notify_at_hour
    end

    test "rejects hour values below 8", %{
      user: user,
      momentum: momentum,
      task_blueprint: task_blueprint
    } do
      attrs = %{
        user_id: user.id,
        task_blueprint_id: task_blueprint.id,
        momentum_id: momentum.id,
        status: :pending,
        target_date: Date.utc_today(),
        day_number: 1,
        affect_value: Decimal.new("5"),
        name: "Test Task",
        icon: "📋",
        notify_at_hour: 7,
        notify_at_minute: 30
      }

      changeset = Task.changeset(%Task{}, attrs)
      refute changeset.valid?
      assert "must be between 8 and 23" in errors_on(changeset).notify_at_hour
    end

    test "rejects invalid minute values", %{
      user: user,
      momentum: momentum,
      task_blueprint: task_blueprint
    } do
      attrs = %{
        user_id: user.id,
        task_blueprint_id: task_blueprint.id,
        momentum_id: momentum.id,
        status: :pending,
        target_date: Date.utc_today(),
        day_number: 1,
        affect_value: Decimal.new("5"),
        name: "Test Task",
        icon: "📋",
        notify_at_hour: 10,
        notify_at_minute: 15
      }

      changeset = Task.changeset(%Task{}, attrs)
      refute changeset.valid?
      assert "must be one of: 0, 10, 20, 30, 40, 50" in errors_on(changeset).notify_at_minute
    end

    test "accepts valid hour and minute combinations", %{
      user: user,
      momentum: momentum,
      task_blueprint: task_blueprint
    } do
      valid_combinations = [
        {8, 0},
        {8, 10},
        {8, 20},
        {8, 30},
        {8, 40},
        {8, 50},
        {12, 0},
        {12, 10},
        {12, 20},
        {12, 30},
        {12, 40},
        {12, 50},
        {23, 0},
        {23, 10},
        {23, 20},
        {23, 30},
        {23, 40},
        {23, 50}
      ]

      for {hour, minute} <- valid_combinations do
        attrs = %{
          user_id: user.id,
          task_blueprint_id: task_blueprint.id,
          momentum_id: momentum.id,
          status: :pending,
          target_date: Date.utc_today(),
          day_number: 1,
          affect_value: Decimal.new("5"),
          name: "Test Task",
          icon: "📋",
          notify_at_hour: hour,
          notify_at_minute: minute
        }

        changeset = Task.changeset(%Task{}, attrs)
        assert changeset.valid?, "Failed for hour: #{hour}, minute: #{minute}"
      end
    end
  end

  # Helper functions for creating test data
  defp momentum_fixture(momentum_blueprint) do
    %MomentumHq.MissionControl.Momentum{}
    |> MomentumHq.MissionControl.Momentum.changeset(%{
      momentum_blueprint_id: momentum_blueprint.id,
      user_id: momentum_blueprint.user_id,
      day_number: 1
    })
    |> Repo.insert!()
  end
end
