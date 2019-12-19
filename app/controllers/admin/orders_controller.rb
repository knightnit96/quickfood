class Admin::OrdersController < Admin::ApplicationController
  before_action :check_active

  authorize_resource

  def index
    @orders = Order.by_date
  end

  private

  def check_active
    @active = "order"
  end
end
