module ProductsHelper
  def product_status(product)
    lato_data_badge(Product.human_attribute_name("status.#{product.status}"), product.status_color)
  end

  def product_created_at(product)
    product.created_at.strftime('%d/%m/%Y')
  end

  def product_lato_user_id(product)
    lato_data_user(product.lato_user.full_name, product.lato_user.gravatar_image_url(50))
  end

  def product_product_parent_id(product)
    return ' - ' if product.product_parent.nil?

    product.product_parent.code
  end

  def product_lifetime(product)
    Time.at(product.lifetime).utc.strftime('%H h %M m')
  end

  def product_actions(product)
    content_tag(:div, class: 'btn-group btn-group-sm') do
      concat link_to('Modifica', products_update_path(product), class: 'btn btn-primary', data: { lato_action_target: 'trigger', turbo_frame: dom_id(product, 'form') })
      concat link_to('Delete', '#', class: 'btn btn-danger', data: { turbo_method: 'POST', turbo_confirm: 'Are you sure to continue?' })
    end
  end
end
