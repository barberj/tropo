class Api::V1::GetRequestsController < Api::V1::RequestsController

  MISSING_PARAM = %q(Get Requests Params must include either created_since, updated_since, identifiers, or search_by)

  def index
    status, results = case
    when params[:updated_since]
      attempt_request(:updated, params[:resource], updated_params)
    when params[:created_since]
      if api.can_request_created?(params[:resource])
        api.request_created(params[:resource], created_params)
      else
        [
          :unprocessable_entity,
          message: UNSUPPORTED_ACTION
        ]
      end
    when params[:identifiers]
      if api.can_request_identifiers?(params[:resource])
        api.request_identifiers(params[:resource], identifiers_params)
      else
        [
          :unprocessable_entity,
          message: UNSUPPORTED_ACTION
        ]
      end
    when params[:search_by]
      if api.can_request_search?(params[:resource])
        api.request_search(params[:resource], search_params)
      else
        [
          :unprocessable_entity,
          message: UNSUPPORTED_ACTION
        ]
      end
    else
      [
        :bad_request,
        message: MISSING_PARAM
      ]
    end

    render json: results, status: status
  end

private

  def attempt_request(request_type, resource, params)
    if api.send(:"can_request_#{request_type}?", resource)
      api.send(:"request_#{request_type}", resource, params)
    else
      [
        :unprocessable_entity,
        message: UNSUPPORTED_ACTION
      ]
    end
  end

  def created_params
    params.permit(
      :created_since,
      :page,
      :limit
    ).symbolize_keys
  end

  def updated_params
    params.permit(
      :updated_since,
      :page,
      :limit
    ).symbolize_keys
  end

  def identifier_params
    params.permit(
      :identifiers,
      :page,
      :limit
    ).symbolize_keys
  end

  def search_params
    params.permit(
      :search_by,
      :page,
      :limit
    ).symbolize_keys
  end
end
