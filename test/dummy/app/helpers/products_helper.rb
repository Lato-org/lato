module ProductsHelper
  def product_status(product)
    product.status.humanize
  end

  def product_created_at(product)
    product.created_at.strftime('%d/%m/%Y')
  end

  def product_lato_user_id(product)
    product.lato_user.full_name
  end

  def product_lifetime(product)
    Time.at(product.lifetime).utc.strftime('%H h %M m')
  end

  def product_actions(product)
    content_tag(:div, class: 'btn-group btn-group-sm') do
      concat link_to('Modifica', products_update_path(product), class: 'btn btn-primary', data: { lato_index_target: 'action', turbo_frame: dom_id(product, 'form') })
      # concat link_to('<i class="bi bi-trash"></i>', '#', class: 'btn btn-danger')
    end
  end
end
