class CreateProductItems < ActiveRecord::Migration[7.1]
  def change
    create_table :product_items do |t|
      t.references :product, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :quantity, null: false, default: 1
      t.timestamps
    end
  end
end
