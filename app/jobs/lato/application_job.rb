module Lato
  # ApplicationJob.
  class ApplicationJob < ActiveJob::Base
    around_perform :manage_operation

    protected

    # This method is used to check if the job is running inside an operation.
    def operation?
      !!@operation
    end

    # This method returns the input file attached to the operation if exists.
    def operation_input_file_attachment
      @operation.input_file.attached? ? @operation.input_file : nil
    end

    # This method can be used to update the percentage of the operation.
    def update_operation_percentage(percentage)
      return false unless operation?

      @operation.update(
        percentage: percentage
      )
    end

    # This method can be used to save a file as output of the operation.
    def save_operation_output_file(file_path)
      return false unless operation?

      file = File.open(file_path)
      file_name = File.basename(file_path)
      @operation.output_file.attach(
        io: file,
        filename: file_name
      )
    end

    # This method can be used to save a text message as output of the operation.
    def save_operation_output_message(message)
      return false unless operation?

      @operation.update(
        active_job_output: @operation.active_job_output.merge(_message: message)
      )

      true
    end

    private

    # This function is used to manage the operation and manage custom errors.
    def manage_operation
      @operation = Lato::Operation.find(arguments.first[:_operation_id]) if arguments.first && arguments.first.is_a?(Hash) && !arguments.first[:_operation_id].blank?
      @operation&.running

      begin
        yield
        @operation&.completed
      rescue StandardError => e
        return @operation.failed(e.message) if @operation

        raise e
      end
    end
  end
end
