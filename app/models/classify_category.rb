class ClassifyCategory < ApplicationRecord
  has_many :child_classify_categories, class_name: ClassifyCategory.name,
    foreign_key: :parent_id, dependent: :destroy
  has_many :classify_places, dependent: :destroy

  scope :parent_only, ->(parent_id){where parent_id: parent_id}
  scope :by_icon, ->(icon){where icon: icon}
  scope :sort_by_parent, ->{order parent_id: :asc}
end
