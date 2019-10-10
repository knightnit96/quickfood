class Food < ApplicationRecord
  belongs_to :place

  has_many :child_foods, class_name: Food.name,
    foreign_key: :parent_id, dependent: :destroy
  has_many :product_orders, dependent: :destroy

  mount_uploader :image, PictureUploader

  scope :by_place, ->(place_id){where place_id: place_id}
  scope :parent_only, ->(parent_id){where parent_id: parent_id}
  scope :child_only, ->{where.not(parent_id: nil)}
  scope :is_not_option, ->{where is_optional: 0}
  scope :is_optional_only, ->(is_optional){where is_optional: is_optional}
  scope :find_food_id, ->(id){where id: id}

  attr_accessor :total_quantity, :total_price
end
