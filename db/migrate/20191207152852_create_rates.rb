class CreateRates < ActiveRecord::Migration[5.1]
  def change
    create_table :rates do |t|
      t.references :place, foreign_key: true
      t.references :user, foreign_key: true
      t.integer :rating
      t.text :content

      t.timestamps
    end
  end
end
