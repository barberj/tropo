class Api < ActiveRecord::Base
  attr_encrypted(:data,
    key: proc { |record| Tropo.secret + record.id.to_s + record.created_at.to_s },
    marshal: true
  )

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
