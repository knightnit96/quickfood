class Address < ApplicationRecord
  belongs_to :user

  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :address, presence: true
  validates :phone, presence: true

  scope :of_current_user, ->(user_id){where user_id: user_id}
  scope :by_user, ->(user_id){where user_id: user_id}
end
