class Order < ApplicationRecord
  belongs_to :place
  belongs_to :user
  belongs_to :shipper, optional: true
  belongs_to :address

  has_many :product_orders, dependent: :destroy
  has_many :messages, dependent: :destroy

  scope :by_user, ->(user_id){where user_id: user_id}
  scope :by_status, ->(status){where status: status}
  scope :by_user_or_shipper, ->(user_id, shipper_id){where("user_id = ? or shipper_id = ?", user_id, shipper_id)}
  scope :by_shipper, ->(shipper_id){where shipper_id: shipper_id}
  scope :by_date, ->{order created_at: :desc}
  scope :by_place, ->(place_id){where place_id: place_id}

  delegate :name, :address, :latitude, :longitude, to: :place, prefix: true
  delegate :user_id, to: :shipper, prefix: true
  delegate :address, :latitude, :longitude, to: :address, prefix: true
  delegate :name, :email, :gender, :avatar, :role, to: :user, prefix: true

  def purchase total_price, token, payer_id
    response = EXPRESS_GATEWAY.purchase(total_price, express_purchase_options(token, payer_id))
    response.success?
  end

  private

  def express_purchase_options token, payer_id
    {
      ip: "192.168.0.34",
      token: token,
      payer_id: payer_id
    }
  end
end
