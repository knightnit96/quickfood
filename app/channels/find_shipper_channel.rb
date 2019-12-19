class FindShipperChannel < ApplicationCable::Channel
  def subscribed
    stream_from "find_shipper_#{current_user.id}_channel"
  end

  def unsubscribed
    stop_all_streams
  end
end
