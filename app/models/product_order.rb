class ProductOrder < ApplicationRecord
  belongs_to :order
  belongs_to :food

  scope :by_order, ->(order_id){where order_id: order_id}
  scope :by_parent, ->(parent_id){where parent_id: parent_id}
  scope :child_only, ->{where.not(parent_id: nil)}

  delegate :name, to: :food, prefix: true
end
