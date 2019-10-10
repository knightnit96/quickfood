class Message < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :order

  scope :by_order, ->(order_id){where order_id: order_id}
end
