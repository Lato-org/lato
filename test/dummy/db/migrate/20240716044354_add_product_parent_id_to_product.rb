class AddProductParentIdToProduct < ActiveRecord::Migration[7.1]
  def change
    add_reference :products, :product_parent, foreign_key: { to_table: :products }
  end
end
