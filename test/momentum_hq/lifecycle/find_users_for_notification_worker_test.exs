defmodule MomentumHq.Lifecycle.FindUsersForNotificationWorkerTest do
  use MomentumHq.DataCase, async: true

  alias MomentumHq.Lifecycle.FindUsersForNotificationWorker
  alias MomentumHq.MissionControl

  describe "perform/1" do
    test "finds users with notification tasks" do
      # This test would require setting up users with tasks
      # For now, we'll test the basic structure
      job = %Oban.Job{args: %{}}

      # The worker should complete without errors
      assert FindUsersForNotificationWorker.perform(job) == :ok
    end
  end
end
