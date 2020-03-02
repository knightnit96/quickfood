class CreateAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :addresses do |t|
      t.string :common_name
      t.string :name
      t.string :address
      t.string :phone
      t.references :user, foreign_key: true
      t.string :longitude
      t.string :latitude

      t.timestamps
    end
  end
end
