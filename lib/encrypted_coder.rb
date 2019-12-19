class EncryptedCoder
  def load value
    return if value.blank?
    Marshal.load Crypt.decrypt(Base64.decode64(value))
  end

  def dump value
    return if value.blank?
    Base64.encode64 Crypt.encrypt(Marshal.dump(value))
  end
end
