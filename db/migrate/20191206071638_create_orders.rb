class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.references :place, foreign_key: true
      t.float :total_price
      t.integer :status, default: 0
      t.references :shipper, foreign_key: true
      t.integer :payment, default: 0
      t.references :address, foreign_key: true

      t.timestamps
    end
  end
end
