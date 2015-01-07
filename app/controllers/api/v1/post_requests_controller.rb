class Api::V1::PostRequestsController < Api::V1::RequestsController
  UNSUPPORTED_ACTION = %q(Can not request %{type} for %{api}'s %{resource}.)

  def create
    status, results = if api.can_request_create?(resource)
      [
        :ok,
        results: api.request_create(resource, create_param)
      ]
    else
      [
        :unprocessable_entity,
        message: UNSUPPORTED_ACTION % {
          api: api.name,
          type: :create,
          resource: resource.capitalize
        }
      ]
    end

    render json: results, status: status
  end

private

  def create_params
    params.permit(:data)
  end
end
