class CreateShippers < ActiveRecord::Migration[5.1]
  def change
    create_table :shippers do |t|
      t.references :user, foreign_key: true
      t.references :province, foreign_key: true
      t.string :identity_card
      t.boolean :activated, default: false
      t.integer :status, default: 0
      t.string :longitude
      t.string :latitude

      t.timestamps
    end
  end
end
