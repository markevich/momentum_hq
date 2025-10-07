defmodule MomentumHq.Blueprinting.TaskBlueprintTest do
  use MomentumHqDataCase, async: true

  alias MomentumHq.Blueprinting.TaskBlueprint

  import MomentumHq.AccountsFixtures
  import MomentumHq.BlueprintingFixtures

  describe "notification time validation" do
    setup do
      user = user_fixture()
      momentum_blueprint = momentum_blueprint_fixture(user)
      %{user: user, momentum_blueprint: momentum_blueprint}
    end

    test "validates notification time when both hour and minute are provided", %{
      user: user,
      momentum_blueprint: momentum_blueprint
    } do
      attrs = %{
        name: "Test Task",
        schedules: [1, 2, 3],
        color: "blue",
        momentum_blueprint_id: momentum_blueprint.id,
        user_id: user.id,
        notify_at_hour: 10,
        notify_at_minute: 30
      }

      changeset = TaskBlueprint.changeset(%TaskBlueprint{}, attrs)
      assert changeset.valid?
    end

    test "validates notification time when both are nil", %{
      user: user,
      momentum_blueprint: momentum_blueprint
    } do
      attrs = %{
        name: "Test Task",
        schedules: [1, 2, 3],
        color: "blue",
        momentum_blueprint_id: momentum_blueprint.id,
        user_id: user.id,
        notify_at_hour: nil,
        notify_at_minute: nil
      }

      changeset = TaskBlueprint.changeset(%TaskBlueprint{}, attrs)
      assert changeset.valid?
    end

    test "rejects when only hour is provided", %{
      user: user,
      momentum_blueprint: momentum_blueprint
    } do
      attrs = %{
        name: "Test Task",
        schedules: [1, 2, 3],
        color: "blue",
        momentum_blueprint_id: momentum_blueprint.id,
        user_id: user.id,
        notify_at_hour: 10,
        notify_at_minute: nil
      }

      changeset = TaskBlueprint.changeset(%TaskBlueprint{}, attrs)
      refute changeset.valid?

      assert "both hour and minute must be set or both must be nil" in errors_on(changeset).notify_at_hour
    end

    test "rejects when only minute is provided", %{
      user: user,
      momentum_blueprint: momentum_blueprint
    } do
      attrs = %{
        name: "Test Task",
        schedules: [1, 2, 3],
        color: "blue",
        momentum_blueprint_id: momentum_blueprint.id,
        user_id: user.id,
        notify_at_hour: nil,
        notify_at_minute: 30
      }

      changeset = TaskBlueprint.changeset(%TaskBlueprint{}, attrs)
      refute changeset.valid?

      assert "both hour and minute must be set or both must be nil" in errors_on(changeset).notify_at_hour
    end

    test "rejects invalid hour values", %{user: user, momentum_blueprint: momentum_blueprint} do
      attrs = %{
        name: "Test Task",
        schedules: [1, 2, 3],
        color: "blue",
        momentum_blueprint_id: momentum_blueprint.id,
        user_id: user.id,
        notify_at_hour: 25,
        notify_at_minute: 30
      }

      changeset = TaskBlueprint.changeset(%TaskBlueprint{}, attrs)
      refute changeset.valid?
      assert "must be between 8 and 23" in errors_on(changeset).notify_at_hour
    end

    test "rejects hour values below 8", %{user: user, momentum_blueprint: momentum_blueprint} do
      attrs = %{
        name: "Test Task",
        schedules: [1, 2, 3],
        color: "blue",
        momentum_blueprint_id: momentum_blueprint.id,
        user_id: user.id,
        notify_at_hour: 7,
        notify_at_minute: 30
      }

      changeset = TaskBlueprint.changeset(%TaskBlueprint{}, attrs)
      refute changeset.valid?
      assert "must be between 8 and 23" in errors_on(changeset).notify_at_hour
    end

    test "rejects invalid minute values", %{user: user, momentum_blueprint: momentum_blueprint} do
      attrs = %{
        name: "Test Task",
        schedules: [1, 2, 3],
        color: "blue",
        momentum_blueprint_id: momentum_blueprint.id,
        user_id: user.id,
        notify_at_hour: 10,
        notify_at_minute: 15
      }

      changeset = TaskBlueprint.changeset(%TaskBlueprint{}, attrs)
      refute changeset.valid?
      assert "must be one of: 0, 10, 20, 30, 40, 50" in errors_on(changeset).notify_at_minute
    end

    test "accepts valid hour and minute combinations", %{
      user: user,
      momentum_blueprint: momentum_blueprint
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
          name: "Test Task",
          schedules: [1, 2, 3],
          color: "blue",
          momentum_blueprint_id: momentum_blueprint.id,
          user_id: user.id,
          notify_at_hour: hour,
          notify_at_minute: minute
        }

        changeset = TaskBlueprint.changeset(%TaskBlueprint{}, attrs)
        assert changeset.valid?, "Failed for hour: #{hour}, minute: #{minute}"
      end
    end
  end
end
