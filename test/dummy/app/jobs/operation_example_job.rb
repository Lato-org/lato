class OperationExampleJob < ApplicationJob
  def perform(params = {})
    if params['type'] == 'success'
      5.times { sleep(1) }
      save_operation_output_message("Custom operation success message")
      return
    end

    if params['type'] == 'success_action'
      5.times { sleep(1) }
      save_operation_output_message("Custom operation success message and action")
      save_operation_output_action('Visit the homepage', Rails.application.routes.url_helpers.root_path, target: '_blank')
      return
    end

    if params['type'] == 'file'
      5.times { sleep(1) }
      save_operation_output_file(Rails.root.join('tmp', 'pids', 'server.pid'))
      return
    end

    if params['type'] == 'failed'
      5.times { sleep(1) }
      raise "Custom operation error message"
      return
    end

    if params['type'] == 'percentage'
      10.times do |index|
        sleep(1)
        update_operation_percentage((index + 1) * 10)
      end
      return
    end

    if params['type'] == 'logs_add'
      10.times do |index|
        sleep(1)
        add_operation_log("Custom log message #{index + 1}")
      end
      return
    end

    if params['type'] == 'logs_replace'
      10.times do |index|
        sleep(1)
        if index % 2 == 0
          replace_operation_log("Custom long long long and detailed long log message #{index + 1} that will replace the previous log")
        else
          replace_operation_log("Custom log message #{index + 1}")
        end
      end
      return
    end

    if params['type'] == 'file_input'
      5.times { sleep(1) }
      save_operation_output_message("You have uploaded the file #{operation_input_file_attachment.filename}")
      return
    end

    5.times { sleep(1) }
  end
end
