module ProfilesHelper
  def load_name user_id
    @user = User.find_by id: user_id
    @user.name
  end

  def load_payment payment
    if payment.zero?
      "Thanh toán bằng tiền mặt"
    elsif payment == 1
      "Thanh toán bằng thẻ tín dụng"
    elsif payment == 2
      "Thanh toán bằng Paypal"
    end
  end

  def load_status status
    if status.zero?
      "Đang xác nhận"
    elsif status == 1
      "Đang tìm tài xế"
    elsif status == 2
      "Đang nhận hàng"
    elsif status == 3
      "Đang giao hàng"
    elsif status == 4
      "Đã xong"
    elsif status == 5
      "Đã hủy"
    end
  end
end
