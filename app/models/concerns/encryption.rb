module Encryption
  extend ActiveSupport::Concern

  included do
    around_create :init_encryption
  end

private

  def init_encryption
    to_encrypt = self.data || {} if self.class.encrypting

    yield

    if self.class.encrypting
      self.data = to_encrypt
      self.save
    end
  end
end
