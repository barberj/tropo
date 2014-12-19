class Api < ActiveRecord::Base
  encrypted_data(:client_data)

  around_create :init_encryption

  def name
    self.class.name
  end

private

  def init_encryption
    to_encrypt = self.data || {}

    yield

    self.data = to_encrypt
    self.save
  end

end
