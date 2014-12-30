class Api::V1::RequestsController < ActionController::Base
  respond_to :json
  before_action :authorize!, :normalize_resource!

private

  def token
    @token ||= (request.headers
      .fetch("HTTP_AUTHENTICATION", "")
      .match(/Token (.*)/) || [])[1]
  end

  def api
    @api ||= Api.find_by(token: token)
  end

  def authorize!
    head :unauthorized unless api
  end

  def normalize_resource!
    params['resource'] = params['resource'].downcase
  end
end
