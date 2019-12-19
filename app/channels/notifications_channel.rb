class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notification_order_#{current_user.id}_channel"
  end

  def unsubscribed
    stop_all_streams
  end
end
