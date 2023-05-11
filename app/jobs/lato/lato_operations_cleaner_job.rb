module Lato
  class LatoOperationsCleanerJob < Lato::ApplicationJob
    def perform
      # delete all operations that are not running and are older than 12 hours
      Lato::Operation.where.not(status: :running).where('lato_operations.created_at < ?', 12.hours.ago).find_in_batches do |operations|
        operations.each(&:destroy)
      end
    end
  end
end
