class Shipper < ApplicationRecord
  belongs_to :user
  belongs_to :province

  has_many :orders, dependent: :destroy

  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode

  scope :by_online, ->{where status: 1}
  scope :activated, ->{where activated: true}
  scope :by_date, ->{order created_at: :desc}

  delegate :name, :email, :gender, :avatar, :role, to: :user, prefix: true
  delegate :name, to: :province, prefix: true
end
