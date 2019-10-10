class Rate < ApplicationRecord
  belongs_to :user
  belongs_to :place

  attr_accessor :user_avatar

  scope :place_reviews, ->(place_id){where place_id: place_id}
  scope :by_date, ->{order updated_at: :desc}
end
