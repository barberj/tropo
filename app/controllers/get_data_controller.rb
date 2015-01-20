class GetDataController < DataController

  def index
    case
    when params[:updated_since]
      attempt_api_request(:updated, updated_params)
    when params[:created_since]
      attempt_api_request(:created, created_params)
    when params[:identifiers]
      attempt_api_request(:identifiers, identifiers_params)
    when params[:search_by]
      attempt_api_request(:search, search_params)
    else
      raise Exceptions::ApiError.new(
        %q(Get request must include either created_since, updated_since, identifiers, or search_by.)
      )
    end
  end

private

  def attempt_api_request(request_type, request_params)
    if api.send(:"can_request_#{request_type}?", resource)
      render(
        json: { results: api.send(:"request_#{request_type}", resource, request_params) },
        status: :ok
      )
    else
      raise Exceptions::Unprocessable.new(UNSUPPORTED_ACTION % {
        api: api.name,
        type: request_type,
        resource: resource.capitalize
      })
    end
  end

  def normalize_time(key, values)
    values[key] = Time.strptime(values[key], '%FT%T%z').utc
  rescue
    raise Exceptions::ApiError.new(
      %Q(#{key} requires format "YYYY-mm-ddTHH:MM:SS-Z")
    )
  end

  def normalize_offsets(values)
    values[:page] = values[:page].to_i
    values[:limit] = values[:limit].to_i
  end

  def created_params
    params.permit(
      :created_since,
      :page,
      :limit
    ).symbolize_keys.tap do |p|
      normalize_time(:created_since, p)
      normalize_offsets(p)
    end
  end

  def updated_params
    params.permit(
      :updated_since,
      :page,
      :limit
    ).symbolize_keys.tap do |p|
      normalize_time(:updated_since, p)
      normalize_offsets(p)
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
