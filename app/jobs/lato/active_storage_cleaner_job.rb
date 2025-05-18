module Lato
  class ActiveStorageCleanerJob < Lato::ApplicationJob
    def perform(params = {})
      update_operation_percentage(0)

      # delete all active storage blobs that are not attached to any record with more than 12 hours of life
      query = ActiveStorage::Blob.where('active_storage_blobs.created_at < ?', 12.hours.ago)
      totals = query.count
      runned = 0
      query.find_in_batches do |blobs|
        blobs.each(&:purge_later)
        runned += blobs.size
        update_operation_percentage((runned.to_f / totals * 100).round)
      end

      # delete all empty folders in active storage local service (if exists)
      if ActiveStorage::Blob.service.class.to_s == 'ActiveStorage::Service::DiskService'
        storage_folder = ActiveStorage::Blob.service.root
        return unless File.directory?(storage_folder)

        Dir.foreach(storage_folder) do |folder|
          next if folder == '.' || folder == '..'

          folder_path = File.join(ActiveStorage::Blob.service.root, folder)
          FileUtils.rm_rf(folder_path) if File.directory?(folder_path) && Dir.empty?(folder_path)
        end
      end
    end
  end
end