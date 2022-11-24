module Lato
  class Operation < ApplicationRecord
    enum status: {
      created: 0,
      running: 1,
      completed: 2,
      failed: 3
    }, _suffix: true

    has_one_attached :input_file
    has_one_attached :output_file

    # Hooks
    ##

    before_create do
      self.status = :created
      self.active_job_input ||= {}
      self.active_job_output ||= {}
    end

    # Questions
    ##

    def finished?
      completed_status? || failed_status?
    end

    def output_message?
      active_job_output && !active_job_output['_message'].blank?
    end

    def output_error?
      active_job_output && !active_job_output['_error'].blank?
    end

    def output_file?
      output_file.attached?
    end

    # Helpers
    ##

    def output_error
      active_job_output['_error']
    end

    def output_message
      active_job_output['_message']
    end

    # Operations

    def start
      begin
        active_job_name.constantize.perform_later(active_job_input.merge(_operation_id: id))
      rescue StandardError
        errors.add(:base, 'Impossibile eseguire il job')
        return false
      end

      true
    end

    def running
      update(status: :running)
    end

    def failed(error = nil)
      update(
        status: :failed,
        closed_at: Time.now,
        active_job_output: error ? active_job_output.merge(_error: error) : active_job_output
      )
    end

    def completed(message = nil)
      update(
        status: :completed,
        closed_at: Time.now,
        active_job_output: message ? active_job_output.merge(_message: message) : active_job_output
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
