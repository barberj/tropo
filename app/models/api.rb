class Api < ActiveRecord::Base
  attr_encrypted(:data,
    key: proc { |record| Tropo.secret + record.id.to_s + record.created_at.to_s },
    marshal: true
  )
end
