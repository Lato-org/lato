require 'csv'

class ExportProductsJob < ApplicationJob
  def perform(params = {})
    # generate csv on tmp directory
    tmp_file_path = Rails.root.join('tmp', "ExportProductsJob_#{Time.now.to_i}.csv")
    generate_csv(tmp_file_path)

    # return file directory if job is not executed as operation
    return tmp_file_path unless operation?

    # save output to uperation
    save_operation_output_file(tmp_file_path)
    save_operation_output_message("Esportati #{Product.all.count} prodotti")
  end

  private

  def generate_csv(file_path)
    CSV.open(file_path, 'wb') do |csv|
      csv << Product.attribute_names
      Product.find_in_batches do |batch|
        batch.each do |product|
          csv << product.attributes.values
        end
      end
    end
  end
end
