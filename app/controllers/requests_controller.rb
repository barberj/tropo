class Api::V1::RequestsController < ActionController::Base
  respond_to :json
  before_action :authorize!, :normalize_resource!

  attr_reader :resource

  UNAUTHORIZED = %q(%{api} is not authorized. Please fix your authorization on %{api} and then retry.)
  UNSUPPORTED_ACTION = %q(Can not request %{type} for %{api}'s %{resource}.)

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

  rescue_from ActionController::ParameterMissing do
    render(
      json: {
        message: %Q(#{request_method.capitalize} Requests must include data.)
      },
      status: :bad_request
    )
  end

  rescue_from Exceptions::Unprocessable do |exception|
    render(
      json: { message: exception.message },
      status: :unprocessable_entity
    )
  end

private

  def request_method
    request.env['REQUEST_METHOD']
  end

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
    @resource = params['resource'] = params['resource'].downcase
  end
end
