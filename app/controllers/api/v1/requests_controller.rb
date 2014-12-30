class Api::V1::RequestsController < ActionController::Base
  respond_to :json
  before_action :authenticate!

private

  def token
    @token ||= (request.headers
      .fetch("HTTP_AUTHORIZATION", "")
      .match(/Token (.*)/) || [])[1]
  end

  def api
    @api ||= Api.find_by(token: token)
  end

  def authenticate!
    head :unauthorized unless api
  end
end
