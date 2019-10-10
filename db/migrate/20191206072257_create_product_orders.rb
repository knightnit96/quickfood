class CreateProductOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :product_orders do |t|
      t.references :order, foreign_key: true
      t.references :food, foreign_key: true
      t.float :actual_price
      t.integer :quantity
      t.bigint :parent_id

      t.timestamps
    end

    add_foreign_key :product_orders, :product_orders, column: :parent_id
  end
end
