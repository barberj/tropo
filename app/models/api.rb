class Api < ActiveRecord::Base
  include Requests

  encrypted_data(:client_data)

  def name
    self.class.name
  end

end
