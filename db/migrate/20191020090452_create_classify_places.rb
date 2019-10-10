class CreateClassifyPlaces < ActiveRecord::Migration[5.1]
  def change
    create_table :classify_places do |t|
      t.references :place, foreign_key: true
      t.references :classify_category, foreign_key: true

      t.timestamps
    end
  end
end
