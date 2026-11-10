require "test_helper"

module Lato
  class OperationTest < ActiveSupport::TestCase
    test "start refuses classes that are not operation jobs" do
      operation = Lato::Operation.create!(active_job_name: "ActiveStorage::PurgeJob", active_job_input: {}, status: :created, percentage: 0)

      assert_not operation.start
      assert operation.errors.added?(:base, :start_error)
    end

    test "start enqueues operation jobs" do
      operation = Lato::Operation.create!(active_job_name: "OperationExampleJob", active_job_input: { type: "success" }, status: :created, percentage: 0)

      assert operation.start
    end
  end
end
