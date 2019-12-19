class AddFeeToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :fee, :float, default: 0
  end
end
