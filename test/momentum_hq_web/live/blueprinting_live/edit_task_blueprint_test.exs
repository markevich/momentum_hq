defmodule MomentumHqWeb.BlueprintingLive.EditTaskBlueprintTest do
  use MomentumHqWeb.ConnCase, async: true

  import MomentumHq.AccountsFixtures
  import MomentumHq.BlueprintingFixtures

  alias MomentumHq.Blueprinting

  describe "EditTaskBlueprint LiveView" do
    setup do
      user = user_fixture()
      momentum_blueprint = momentum_blueprint_fixture(user)
      task_blueprint = task_blueprint_fixture(momentum_blueprint)

      %{
        user: user,
        momentum_blueprint: momentum_blueprint,
        task_blueprint: task_blueprint
      }
    end

    test "update/2 sets notification_enabled correctly when notification is enabled", %{
      user: user,
      momentum_blueprint: momentum_blueprint,
      task_blueprint: task_blueprint
    } do
      # Update task blueprint to have notification settings
      {:ok, updated_blueprint} = Blueprinting.update_task_blueprint(task_blueprint, %{
        "notify_at_hour" => 10,
        "notify_at_minute" => 30
      })

      assigns = %{
        task_blueprint: updated_blueprint,
        momentum_blueprint: momentum_blueprint,
        user_id: user.id,
        action: :edit_task_blueprint,
        patch: "/blueprinting"
      }

      # Test the update function directly
      {:ok, socket} = MomentumHqWeb.BlueprintingLive.EditTaskBlueprint.update(assigns, %Phoenix.LiveView.Socket{})

      # Check that notification_enabled is set correctly
      assert socket.assigns.notification_enabled == true
    end

    test "update/2 sets notification_enabled correctly when notification is disabled", %{
      user: user,
      momentum_blueprint: momentum_blueprint,
      task_blueprint: task_blueprint
    } do
      assigns = %{
        task_blueprint: task_blueprint,
        momentum_blueprint: momentum_blueprint,
        user_id: user.id,
        action: :edit_task_blueprint,
        patch: "/blueprinting"
      }

      # Test the update function directly
      {:ok, socket} = MomentumHqWeb.BlueprintingLive.EditTaskBlueprint.update(assigns, %Phoenix.LiveView.Socket{})

      # Check that notification_enabled is set correctly
      assert socket.assigns.notification_enabled == false
    end

    test "update/2 sets days_options correctly for weekly momentum", %{
      user: user,
      momentum_blueprint: momentum_blueprint,
      task_blueprint: task_blueprint
    } do
      assigns = %{
        task_blueprint: task_blueprint,
        momentum_blueprint: momentum_blueprint,
        user_id: user.id,
        action: :edit_task_blueprint,
        patch: "/blueprinting"
      }

      # Test the update function directly
      {:ok, socket} = MomentumHqWeb.BlueprintingLive.EditTaskBlueprint.update(assigns, %Phoenix.LiveView.Socket{})

      # Check that days_options are set correctly for weekly
      expected_days = [{"Пн", 1}, {"Вт", 2}, {"Ср", 3}, {"Чт", 4}, {"Пт", 5}, {"Сб", 6}, {"Вс", 7}]
      assert socket.assigns.days_options == expected_days
    end

    test "update/2 sets days_options correctly for biweekly momentum", %{
      user: user
    } do
      # Create biweekly momentum blueprint
      biweekly_blueprint = momentum_blueprint_fixture(user, %{generator_type: :biweekly})
      biweekly_task_blueprint = task_blueprint_fixture(biweekly_blueprint)

      assigns = %{
        task_blueprint: biweekly_task_blueprint,
        momentum_blueprint: biweekly_blueprint,
        user_id: user.id,
        action: :edit_task_blueprint,
        patch: "/blueprinting"
      }

      # Test the update function directly
      {:ok, socket} = MomentumHqWeb.BlueprintingLive.EditTaskBlueprint.update(assigns, %Phoenix.LiveView.Socket{})

      # Check that days_options are set correctly for biweekly
      expected_days = [
        {"Пн", 1}, {"Вт", 2}, {"Ср", 3}, {"Чт", 4}, {"Пт", 5}, {"Сб", 6}, {"Вс", 7},
        {"Пн", 8}, {"Вт", 9}, {"Ср", 10}, {"Чт", 11}, {"Пт", 12}, {"Сб", 13}, {"Вс", 14}
      ]
      assert socket.assigns.days_options == expected_days
    end

    test "handle_event toggle_notification updates notification_enabled", %{
      user: user,
      momentum_blueprint: momentum_blueprint,
      task_blueprint: task_blueprint
    } do
      assigns = %{
        task_blueprint: task_blueprint,
        momentum_blueprint: momentum_blueprint,
        user_id: user.id,
        action: :edit_task_blueprint,
        patch: "/blueprinting",
        notification_enabled: false
      }

      socket = %Phoenix.LiveView.Socket{
        assigns: Map.merge(assigns, %{
          flash: %{},
          __changed__: %{}
        })
      }

      # Test toggle to enabled (simulating real browser behavior)
      {:noreply, updated_socket} = MomentumHqWeb.BlueprintingLive.EditTaskBlueprint.handle_event(
        "toggle_notification",
        %{"value" => "on"},
        socket
      )

      assert updated_socket.assigns.notification_enabled == true

      # Test toggle to disabled
      {:noreply, updated_socket} = MomentumHqWeb.BlueprintingLive.EditTaskBlueprint.handle_event(
        "toggle_notification",
        %{"value" => "on"},
        updated_socket
      )

      assert updated_socket.assigns.notification_enabled == false
    end

    test "handle_event save clears notification fields when disabled", %{
      user: user,
      momentum_blueprint: momentum_blueprint,
      task_blueprint: task_blueprint
    } do
      # First set notification settings
      {:ok, _} = Blueprinting.update_task_blueprint(task_blueprint, %{
        "notify_at_hour" => 10,
        "notify_at_minute" => 30
      })

      assigns = %{
        task_blueprint: Blueprinting.get_task_blueprint!(task_blueprint.id),
        momentum_blueprint: momentum_blueprint,
        user_id: user.id,
        action: :edit_task_blueprint,
        patch: "/blueprinting",
        notification_enabled: false
      }

      socket = %Phoenix.LiveView.Socket{
        assigns: Map.merge(assigns, %{
          flash: %{},
          __changed__: %{}
        })
      }

      # Test save with notification disabled
      {:noreply, _updated_socket} = MomentumHqWeb.BlueprintingLive.EditTaskBlueprint.handle_event(
        "save",
        %{"task_blueprint" => %{"name" => "Updated Task"}},
        socket
      )

      # Check that the task blueprint was updated and notification fields were cleared
      updated_blueprint = Blueprinting.get_task_blueprint!(task_blueprint.id)
      assert updated_blueprint.name == "Updated Task"
      assert updated_blueprint.notify_at_hour == nil
      assert updated_blueprint.notify_at_minute == nil
    end

    test "handle_event save preserves notification fields when enabled", %{
      user: user,
      momentum_blueprint: momentum_blueprint,
      task_blueprint: task_blueprint
    } do
      assigns = %{
        task_blueprint: task_blueprint,
        momentum_blueprint: momentum_blueprint,
        user_id: user.id,
        action: :edit_task_blueprint,
        patch: "/blueprinting",
        notification_enabled: true
      }

      socket = %Phoenix.LiveView.Socket{
        assigns: Map.merge(assigns, %{
          flash: %{},
          __changed__: %{}
        })
      }

      # Test save with notification enabled
      {:noreply, _updated_socket} = MomentumHqWeb.BlueprintingLive.EditTaskBlueprint.handle_event(
        "save",
        %{"task_blueprint" => %{
          "name" => "Updated Task",
          "notify_at_hour" => "10",
          "notify_at_minute" => "30"
        }},
        socket
      )

      # Check that the task blueprint was updated with notification fields
      updated_blueprint = Blueprinting.get_task_blueprint!(task_blueprint.id)
      assert updated_blueprint.name == "Updated Task"
      assert updated_blueprint.notify_at_hour == 10
      assert updated_blueprint.notify_at_minute == 30
    end
  end
end
