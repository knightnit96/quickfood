class CancelOrderChannel < ApplicationCable::Channel
  def subscribed
    stream_from "cancel_order_#{current_user.id}_channel"
  end

  def unsubscribed
    stop_all_streams
  end
end
