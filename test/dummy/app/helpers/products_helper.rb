module ProductsHelper
  def product_status(product)
    product.status.humanize
  end

  def product_created_at(product)
    product.created_at.strftime('%d/%m/%Y')
  end

  def products_lato_user_id(product)
    product.lato_user_id # TO-DO
  end
end
