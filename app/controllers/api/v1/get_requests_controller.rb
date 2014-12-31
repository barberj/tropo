class Api::V1::GetRequestsController < Api::V1::RequestsController

  MISSING_PARAM = %q(Get Requests Params must include either created_since, updated_since, identifiers, or search_by.)
  UNSUPPORTED_ACTION = %q(Can not request %{type} for %{api}'s %{resource}.)
  UNAUTHORIZED = %q(%{api} is not authorized. Please fix your authorization on %{api} and then retry.)

  def index
    status, results = process_request(params)
    render json: results, status: status
  end

private

  def process_request(params)
    case
    when params[:updated_since]
      attempt_api_request(:updated, params[:resource], updated_params)
    when params[:created_since]
      attempt_api_request(:created, params[:resource], created_params)
    when params[:identifiers]
      attempt_api_request(:identifiers, params[:resource], identifiers_params)
    when params[:search_by]
      attempt_api_request(:search, params[:resource], search_params)
    else
      [
        :bad_request,
        message: MISSING_PARAM
      ]
    end
  rescue Exceptions::InvalidTimeFormat => ex
    [
      :bad_request,
      message: ex.message
    ]
  end

  def attempt_api_request(request_type, resource, params)
    if api.send(:"can_request_#{request_type}?", resource)
      [
        :ok,
        results: api.send(:"request_#{request_type}", resource, params)
      ]
    else
      [
        :unprocessable_entity,
        message: UNSUPPORTED_ACTION % {
          api: api.name,
          type: request_type,
          resource: resource.capitalize
        }
      ]
    end
  rescue Exceptions::Unauthorized
    [
      :unauthorized,
      message: UNAUTHORIZED % {api: api.name}
    ]
  end

  def normalize_time(key, values)
    values[key] = Time.strptime(values[key], '%FT%T%z').utc
  rescue
    raise Exceptions::InvalidTimeFormat.new(
      %Q(#{key} requires format "YYYY-mm-ddTHH:MM:SS-Z")
    )
  end

  def created_params
    params.permit(
      :created_since,
      :page,
      :limit
    ).symbolize_keys.tap do |p|
      normalize_time(:created_since, p)
    end
  end

  def updated_params
    params.permit(
      :updated_since,
      :page,
      :limit
    ).symbolize_keys.tap do |p|
      normalize_time(:updated_since, p)
    end
  end

  def identifiers_params
    params.permit(
      :identifiers => []
    ).symbolize_keys
  end

  def search_params
    params[:search_by].symbolize_keys
  end
end
