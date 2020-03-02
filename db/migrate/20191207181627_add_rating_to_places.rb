class AddRatingToPlaces < ActiveRecord::Migration[5.1]
  def change
    add_column :places, :rating, :float, default: 0
  end
end
