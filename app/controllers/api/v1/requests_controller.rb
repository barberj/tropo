class Api::V1::RequestsController < ActionController::Base
  respond_to :json
  before_action :authenticate!

private

  def authenticate!
  end
end
