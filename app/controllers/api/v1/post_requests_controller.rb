class Api::V1::PostRequestsController < Api::V1::RequestsController
  def create
    if api.can_request_create?(resource)
      render(
        json: { results: api.request_create(resource, create_params) },
        status: :ok,
      )
    else
      raise Exceptions::Unprocessable.new(UNSUPPORTED_ACTION % {
        api: api.name,
        type: request_type,
        resource: resource.capitalize
      })
    end
  end

private

  def create_params
    Array.wrap(params.require(:data))
  end
end
