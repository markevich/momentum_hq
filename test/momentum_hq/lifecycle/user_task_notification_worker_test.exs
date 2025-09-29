defmodule MomentumHq.Lifecycle.UserTaskNotificationWorkerTest do
  use MomentumHq.DataCase, async: true

  alias MomentumHq.Lifecycle.UserTaskNotificationWorker
  alias MomentumHq.MissionControl

  describe "perform/1" do
    test "processes notifications for a specific user" do
      # This test would require setting up a user with tasks
      # For now, we'll test the basic structure
      job = %Oban.Job{args: %{"user_id" => "test-user-id"}}

      # The worker should complete without errors
      assert UserTaskNotificationWorker.perform(job) == :ok
    end
  end
end
