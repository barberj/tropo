class Insightly < Api

  def request(method, resource, params={})
    rsp = http(method, "https://api.insight.ly/v2.1/#{resource}",
      :query      => params,
      :basic_auth => { :username => data[:api_key] }
    )
    raise Exceptions::Unauthorized if rsp.code == 401
    raise Exceptions::ApiError if rsp.code != 200
    rsp
  end

  def request_page(resource, page, limit, filter={})
    request(:get, 'Contacts',
      filter.merge(
        '$top'    => limit,
        '$skip'   => offset_for_page(:page => page, :limit => limit),
      )
    )
  end

  def search_contacts(email:)
    request(:get, 'Contacts', :email => email)
  end

  def new_contacts(created_since: 1.week.ago, limit: 250, page: 1)
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
end
