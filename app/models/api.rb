class Api < ActiveRecord::Base
  include Requests

  encrypted_data(:client_data)

  def name
    self.class.name
  end

  def offset_for_page(page: 1, limit: 250)
    (page - 1) * limit
  end
end
