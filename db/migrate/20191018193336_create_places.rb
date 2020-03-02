class CreatePlaces < ActiveRecord::Migration[5.1]
  def change
    create_table :places do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.string :address
      t.references :category, foreign_key: true
      t.references :province, foreign_key: true
      t.string :detail_direction
      t.string :phone
      t.string :email
      t.string :website
      t.text :description
      t.string :longitude
      t.string :latitude
      t.integer :capacity
      t.string :start_time
      t.string :close_time
      t.float :average_price, default: 0
      t.boolean :activated, default: false
      t.boolean :is_proposal, default: true

      t.timestamps
    end

    add_index :places, [:name, :description, :address], type: :fulltext
  end
end
