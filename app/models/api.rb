class Api < ActiveRecord::Base
  encrypted_data(:client_data)

  def name
    self.class.name
  end

end
