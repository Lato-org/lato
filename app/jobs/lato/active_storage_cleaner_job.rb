module Lato
  class ActiveStorageCleanerJob < Lato::ApplicationJob
    def perform(params = {})
      update_operation_percentage(0)

      # delete all active storage blobs that are not attached to any record older than the minimum age (default 12 hours)
      min_age_hours = (params[:min_age_hours] || params['min_age_hours'] || 12).to_i
      query = ActiveStorage::Blob.joins("LEFT JOIN active_storage_attachments ON active_storage_attachments.blob_id = active_storage_blobs.id")
                                 .where("active_storage_attachments.blob_id IS NULL")
                                 .where("active_storage_blobs.created_at < ?", min_age_hours.hours.ago)
      totals = query.count
      runned = 0
      query.find_in_batches do |blobs|
        blobs.each(&:purge_later)
        runned += blobs.size
        update_operation_percentage((runned.to_f / totals * 100).round) if totals.positive?
      end

      # delete all empty folders in active storage local service (if exists)
      storage_folder = ActiveStorage::Blob.service.root if ActiveStorage::Blob.service.class.to_s == 'ActiveStorage::Service::DiskService'
      if storage_folder && File.directory?(storage_folder)
        Dir.foreach(storage_folder) do |folder|
          next if folder == '.' || folder == '..'

          folder_path = File.join(ActiveStorage::Blob.service.root, folder)
          FileUtils.rm_rf(folder_path) if File.directory?(folder_path) && Dir.empty?(folder_path)
        end
      end

      update_operation_percentage(100)
    end
  end
end