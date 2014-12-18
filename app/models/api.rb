class Api < ActiveRecord::Base
  has_many :accounts, dependent: :destroy

  attr_encrypted(:data,
    key: proc { |record| Tropo.secret + record.id.to_s + record.created_at.to_s },
    marshal: true
  )

  def name
    self.class.name
  end
end
