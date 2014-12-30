module ResourceRequests
  extend ActiveSupport::Concern

  def can_request_updated?(resource)
    respond_to? :"updated_#{resource}"
  end

  def can_request_created?(resource)
    respond_to? :"created_#{resource}"
  end

  def reads_one?(resource)
    respond_to? :"read_#{resource.singularize}"
  end

  def reads_many?(resource)
    respond_to? :"read_#{resource}"
  end

  def can_request_identifiers?(resource)
    reads_one?(resource) || reads_many?(resource)
  end

  def can_request_search?(resource)
    respond_to? :"search_#{resource}"
  end

  def request_updated(resource, params)
    send(:"updated_#{resource}", params)
  end

  def request_created(resource, params)
    send(:"created_#{resource}", params)
  end

  def request_identifiers(resource, params)
    identifiers = params[:identifiers]
    if reads_many?(resource)
      send(:"read_#{resource}", identifiers)
    else
      identifiers.flat_map do |identifier|
        send(:"read_#{resource.singularize}", identifier)
      end
    end
  end

  def request_search(resource, params)
    send(:"search_#{resource}", params)
  end
end
