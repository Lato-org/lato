module Lato
  # ApplicationJob.
  class ApplicationJob < ActiveJob::Base
    around_perform :manage_operation

    protected

    def operation?
      !!@operation
    end

    def update_operation_percentage(percentage)
      return false unless operation?

      @operation.update(percentage: percentage)
    end

    def save_operation_output_file(file_path)
      return false unless operation?

      file = File.open(file_path)
      file_name = File.basename(file_path)

      @operation.output_file.attach(
        io: file,
        filename: file_name
      )

      true
    end

    def save_operation_output_message(message)
      return false unless operation?

      @operation.update(active_job_output: @operation.active_job_output.merge(_message: message))

      true
    end

    private

    def manage_operation
      @operation = Lato::Operation.find(arguments.first[:_operation_id]) if arguments.first && arguments.first.is_a?(Hash) && !arguments.first[:_operation_id].blank?
      @operation&.running

      begin
        yield
        @operation&.completed
      rescue StandardError => e
        @operation&.failed(e.message)
      end
    end
  end
end
