class Api < ActiveRecord::Base
  include Requests
  encrypted_data(:client_data)
  validates_with AuthorizationValidator, on: :create

  def name
    self.class.name
  end

  def offset_for_page(page: 1, limit: 250)
    (page - 1) * limit
  end

  def check_authorization
    raise NotImplementedError
  end

  def authorized?
    check_authorization.present?
  rescue Exceptions::Unauthorized
    false
  end
end
