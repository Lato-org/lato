class ExportProductsJob < ApplicationJob
  def perform(params = {}, operation_id = nil)
    Operation.find(operation_id).completed if operation_id
  rescue StandardError => e
    Operation.find(operation_id).failed(e.message) if operation_id
  end
end
