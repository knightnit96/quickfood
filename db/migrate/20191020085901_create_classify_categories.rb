class CreateClassifyCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :classify_categories do |t|
      t.string :name
      t.string :icon
      t.bigint :parent_id

      t.timestamps
    end

    add_foreign_key :classify_categories, :classify_categories, column: :parent_id
    add_index :classify_categories, :name, type: :fulltext
  end
end
