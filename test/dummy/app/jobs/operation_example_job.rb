class OperationExampleJob < ApplicationJob
  def perform(params = {})
    if params['type'] == 'success'
      5.times { sleep(1) }
      save_operation_output_message("Messaggio di successo dell'operazione")
      return
    end

    if params['type'] == 'file'
      5.times { sleep(1) }
      save_operation_output_file(Rails.root.join('tmp', 'pids', 'server.pid'))
      return
    end

    if params['type'] == 'failed'
      5.times { sleep(1) }
      raise "Messaggio di errore dell'operazione"
      return
    end

    if params['type'] == 'percentage'
      10.times do |index|
        sleep(1)
        update_operation_percentage((index + 1) * 10)
      end
      return
    end

    5.times { sleep(1) }
  end
end
