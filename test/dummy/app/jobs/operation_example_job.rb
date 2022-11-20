class OperationExampleJob < ApplicationJob
  def perform(params = {})
    10.times do |i|
      sleep(1)
    end

    throw "Messaggio di errore dell'operazione" if params[:type] == 'failed'

    save_operation_output_message("Messaggio di output dell'operazione")
  end
end
