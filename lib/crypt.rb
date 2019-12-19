module Crypt
  class << self
    ALGO = "aes-128-cbc"
    ENCRYPTION_KEY = ENV["ENCRYPTION_KEY"].to_s

    def encrypt value
      key = encrypt_encryption_key
      crypt :encrypt, value, key, true
    end

    def decrypt value
      crypt :decrypt, value
    end

    def encryption_key encrypted_key
      crypt :decrypt, encrypted_key
    end

    def encrypt_encryption_key
      crypt :encrypt, ENCRYPTION_KEY
    end

    def crypt cipher_method, value, encrypted_key = nil, status = false
      cipher = OpenSSL::Cipher.new ALGO
      cipher.send cipher_method
      cipher.pkcs5_keyivgen status ? encryption_key(encrypted_key) : ENCRYPTION_KEY
      result = cipher.update value
      result << cipher.final
    end
  end
end
