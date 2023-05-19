module Lato
  class ActiveStorageCleanerJob < Lato::ApplicationJob
    def perform
      # delete all active storage blobs that are not attached to any record with more than 12 hours of life
      ActiveStorage::Blob.unattached.where('active_storage_blobs.created_at < ?', 12.hours.ago).find_in_batches do |blobs|
        blobs.each(&:purge_later)
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