class ClassifyPlace < ApplicationRecord
  belongs_to :place
  belongs_to :classify_category

  scope :by_place, ->(place_id){where place_id: place_id}
  delegate :id, :name, :icon, :parent_id, to: :classify_category, prefix: true
end
