class ChatUserChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_with_user_#{current_user.id}_channel"
  end

  def unsubscribed
    stop_all_streams
  end
end
