class Insightly < Api

  def request(method, resource, query: {}, body: {})
    rsp = http(method, "https://api.insight.ly/v2.1/#{resource}",
      :query      => query,
      :body       => body.to_json,
      :basic_auth => { :username => data[:api_key] },
      :headers    => { 'content-type' => 'application/json' }
    )
    raise Exceptions::Unauthorized if rsp.code == 401
    raise Exceptions::ApiError unless rsp.code.in?([200, 201])
    rsp
  end

  def check_authorization
    request(:get, 'Users')
  end

  def get_request(resource, query)
    request(:get, resource, query: query)
  end

  def upsert_request(method, resource, data)
    Array.wrap(request(method, resource, body: data))
  end

  def request_page(resource, page, limit, filter={})
    get_request('Contacts',
      filter.merge(
        '$top'    => limit,
        '$skip'   => offset_for_page(:page => page, :limit => limit),
      )
    )
  end

  def search_contacts(email:)
    get_request('Contacts', :email => email)
  end

  def read_contacts(identifiers)
    get_request('Contacts', :ids => identifiers.join(','))
  end

  def created_contacts(created_since: 1.week.ago, limit: 250, page: 1)
    time_stamp = created_since.utc.strftime('%FT%T')
    request_page('Contacts', page, limit,
      '$filter' => "DATE_CREATED_UTC gt DateTime'#{time_stamp}'"
    )
  end

  def updated_contacts(updated_since: 1.week.ago, limit: 250, page: 1)
    time_stamp = updated_since.utc.strftime('%FT%T')
    request_page('Contacts', page, limit,
      '$filter' => "DATE_UPDATED_UTC gt DateTime'#{time_stamp}'"
    )
  end

  def create_contact(data)
    upsert_request(:post, 'Contacts', data)
  end

  def update_contact(data)
    upsert_request(:put, 'Contacts', data)
  end
end
