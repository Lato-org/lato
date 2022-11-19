class ExportProductsJob < Lato::OperationJob
  def perform(params = {})
    sleep(10) # Do something...
  end
end
