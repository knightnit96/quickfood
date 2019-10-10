class CreateProvinces < ActiveRecord::Migration[5.1]
  def change
    create_table :provinces do |t|
      t.string :name
      t.bigint :parent_id

      t.timestamps
    end

    add_foreign_key :provinces, :provinces, column: :parent_id
    add_index :provinces, :name, type: :fulltext
  end
end
