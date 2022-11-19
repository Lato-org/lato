class ExportProductsJob < ApplicationJob
  def perform(params = {}, operation_id = nil)
    operation = Lato::Operation.find(operation_id)
    10.times do |index|
      sleep(0.25)
      operation.update_percentage((index + 1) * 10)
      sleep(0.25)
    end
    operation.failed('I prodotti non possono essere sportati') if operation_id
  rescue StandardError => e
    Lato::Operation.find(operation_id).failed(e.message) if operation_id
  end
end
