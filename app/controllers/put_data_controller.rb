class PutDataController < DataController

  def update
    if api.can_request_update?(resource)
      render(
        json: { results: api.request_update(resource, update_params) },
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

  def update_params
    Array.wrap(params.require(:data))
  end
end
