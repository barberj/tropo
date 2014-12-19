class ActiveRecord::Base
  extend EncryptedData
  include Encryption
end
