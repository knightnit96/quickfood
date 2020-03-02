class Place < ApplicationRecord
  include SearchCop

  belongs_to :user
  belongs_to :category
  belongs_to :province

  has_many :classify_places, dependent: :destroy
  has_many :foods, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :rates, dependent: :destroy

  scope :of_current_user, ->(user_id){where user_id: user_id}
  scope :is_activated_and_not_proposal, ->{where(activated: true, is_proposal: false)}
  scope :by_province, ->(province_id){where province_id: province_id}
  scope :by_cat, ->(category_id){where category_id: category_id}
  scope :by_proposal, ->(is_proposal){where is_proposal: is_proposal}
  scope :activated, ->{where activated: true}
  search_scope :search_public do
    attributes all: [:name, :description, :address]
    options :all, type: :fulltext
    attributes foods: "foods.name"
    options :foods, type: :fulltext
  end
  scope :by_rating, ->(rating){where("rating >= ?", rating)}
  scope :by_date, ->{order created_at: :desc}
  scope :by_is_proposal, ->{order is_proposal: :desc}
  scope :sort_by_status, ->{order status: :desc}
  scope :by_status, ->(status){where status: status}

  delegate :name, :email, :gender, :avatar, :role, to: :user, prefix: true
  delegate :name, :parent_id, to: :province, prefix: true
  delegate :name, to: :category, prefix: true

  attr_accessor :count_order
end
