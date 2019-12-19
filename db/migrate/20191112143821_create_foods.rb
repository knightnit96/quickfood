class CreateFoods < ActiveRecord::Migration[5.1]
  def change
    create_table :foods do |t|
      t.string :name
      t.float :price
      t.float :discount
      t.bigint :parent_id
      t.integer :is_optional, default: 0
      t.references :place, foreign_key: true
      t.string :image

      t.timestamps
    end

    add_foreign_key :foods, :foods, column: :parent_id
    add_index :foods, :name, type: :fulltext
  end
end
