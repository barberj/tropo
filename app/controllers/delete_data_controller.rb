class DeleteDataController < DataController

  def destroy
    if api.can_request_delete?(resource)
      render(
        json: { results: api.request_delete(resource, delete_params) },
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

  def delete_params
    Array.wrap(params.require(:identifiers))
  end
end
