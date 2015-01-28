class Insightly < Api

  def request(method, resource, query: {}, body: {})
    rsp = http(method, "https://api.insight.ly/v2.1/#{resource}",
      :query      => query,
      :body       => body.to_json,
      :basic_auth => { :username => data[:api_key] },
      :headers    => { 'content-type' => 'application/json' }
    )

    raise Exceptions::Unauthorized if rsp.code == 401
    unless rsp.code.in?([200, 201, 202])
      msg = if rsp.kind_of? Hash
        rsp['Message']
      else
        rsp.body
      end
      raise Exceptions::ApiError.new(msg)
    end

    rsp
  end

  def check_authorization
    request(:get, 'Users')
  end

  def get_request(resource, query)
    request(:get, resource, query: query)
  end

  def simplify_contact_info!(contact)
    contact['CONTACTINFOS'].each do |info|
      case info['TYPE'].upcase
      when 'EMAIL'
        emails = contact[ "#{info['LABEL']}_EMAILS"] ||= []
        emails << info['DETAIL']
      when 'PHONE'
        numbers = contact[ "#{info['LABEL']}_PHONE_NUMBERS"] ||= []
        numbers << info['DETAIL']
      when 'WEBSITE'
        websites = contact[ "#{info['LABEL']}_WEBSITES"] ||= []
        websites << info['DETAIL']
      when 'SOCIAL'
        key = info['LABEL'].include?('LinkedIn') ? 'LINKEDIN' : 'TWITTER'
        socials = contact[key] ||= []
        socials << info['DETAIL']
      end
    end
  end

  def simplify_addresses!(contact)
    contact['ADDRESSES'].each do |address|
      addresses = contact["#{address['ADDRESS_TYPE']}_ADDRESSES"] ||= []
      addresses << address
    end
  end

  def simplify_contacts!(contacts)
    contacts.each do |contact|
      simplify_addresses!(contact)
      simplify_contact_info!(contact)
    end
  end

  def get_contacts(query)
    contacts = get_request('Contacts', query)
    simplify_contacts!(contacts)
  end

  def upsert_request(method, resource, data)
    Array.wrap(request(method, resource, body: data))
  end

  def get_contacts_on_page(page, limit, filter={})
    get_contacts(filter.merge(
      '$top'    => limit,
      '$skip'   => offset_for_page(:page => page, :limit => limit)
    ))
  end

  def search_contacts(email:)
    get_contacts(:email => email)
  end

  def read_contacts(identifiers)
    get_contacts(:ids => identifiers.join(','))
  end

  def created_contacts(created_since: 1.week.ago, limit: 250, page: 1)
    time_stamp = created_since.utc.strftime('%FT%T')
    get_contacts_on_page(page, limit,
      '$filter' => "DATE_CREATED_UTC gt DateTime'#{time_stamp}'"
    )
  end

  def updated_contacts(updated_since: 1.week.ago, limit: 250, page: 1)
    time_stamp = updated_since.utc.strftime('%FT%T')
    get_contacts_on_page(page, limit,
      '$filter' => "DATE_UPDATED_UTC gt DateTime'#{time_stamp}'"
    )
  end

  def format_new_contact_info!(data)
    info = data['CONTACTINFOS'] = []
    ['EMAILS', 'WEBSITES', 'PHONE_NUMBERS', 'SOCIAL'].each do |key|
      info_type = data.delete(key) || []
      info.concat(info_type)
    end

    data
  end

  def create_contact(data)
    format_new_contact_info!(data)
    upsert_request(:post, 'Contacts', data)
  end

  def update_contact(data)
    upsert_request(:put, 'Contacts', data)
  end

  def delete_contact(id)
    request(:delete, "Contacts/#{id}")
  end
end
