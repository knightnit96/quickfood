class UnlockUserMailer < ApplicationMailer
  def unlock_user user, unlock_code
    @user = user
    @unlock_code = unlock_code
    mail to: @user.email, subject: "Unlock user"
  end
end
