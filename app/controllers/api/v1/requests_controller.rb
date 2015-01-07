class Api::V1::RequestsController < ActionController::Base
  respond_to :json
  before_action :authorize!, :normalize_resource!

  UNAUTHORIZED = %q(%{api} is not authorized. Please fix your authorization on %{api} and then retry.)

  rescue_from Exceptions::ApiError do |exception|
    render(
      json: { message: exception.message },
      status: :bad_request,
    )
  end

  rescue_from Exceptions::Unauthorized do
    render(
      json: { message: UNAUTHORIZED % {api: api.name} },
      status: :unauthorized,
    )
  end

private

  def token
    @token ||= (request.headers
      .fetch("HTTP_AUTHORIZATION", "")
      .match(/Token (.*)/) || [])[1]
  end

  def api
    @api ||= Api.find_by(token: token)
  end

  def authorize!
    render(
      json: {message: 'Unauthorized. Please ensure Api is authorized and retry.'},
      status: :unauthorized
    ) if api.nil?
  end

  def normalize_resource!
    params['resource'] = params['resource'].downcase
  end
end
