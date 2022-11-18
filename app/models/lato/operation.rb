module Lato
  class Operation < ApplicationRecord
    enum status: {
      created: 0,
      running: 1,
      completed: 2,
      failed: 3
    }, _suffix: true

    # Hooks
    ##

    before_create do
      self.status = :created
    end

    # Operations

    def run
      begin
        active_job_name.constantize.perform_later(active_job_input, id)
      rescue StandardError
        errors.add(:base, 'Impossibile eseguire il job')
      end

      update(status: :running)
      true
    end

    def failed(error = nil)
      update(
        status: :failed,
        closed_at: Time.now,
        active_job_output: { error: error }
      )
    end

    def completed
      update(
        status: :completed,
        closed_at: Time.now
      )
    end

    # Class
    ##

    def self.generate(active_job_name, active_job_input = {}, user_id = nil)
      Operation.create(
        active_job_name: active_job_name,
        active_job_input: active_job_input,
        lato_user_id: user_id
      )
    end
  end
end
