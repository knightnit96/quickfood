class AddIsShipperToMessages < ActiveRecord::Migration[5.1]
  def change
    add_column :messages, :is_shipper, :boolean, default: false
  end
end
