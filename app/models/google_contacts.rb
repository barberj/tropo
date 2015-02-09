class GoogleContacts < Api

  def refresh_token
    @token = HTTParty.post("https://accounts.google.com/o/oauth2/token",
      :body => {
        "client_id"     => "1026077737604-j4tu3ov7qer2e81b1h7keejb25sebng5.apps.googleusercontent.com",
        "client_secret" => "IJLxxyYUTO0mtI3l_5Q5E36A",
        'refresh_token' => self.data['refresh_token'],
        "grant_type"    => "refresh_token"
      }
    )['access_token']
  end

  def token
    @token || refresh_token
  end

  def simplify_contact(entries)
    [].tap do |contacts|
      Array.wrap(entries).each do |entry|
        contacts << contact = {}
        contact['id'] = entry['id']['$t'].split('/').last
        contact['title'] = Dpaths.dselect(entry, '/title/$t/*')
        contact['content'] = Dpaths.dselect(entry, '/content/$t/*')
        contact['given_name'] = Dpaths.dselect(entry, '/gd$name/gd$givenName/$t/*')
        contact['family_name'] = Dpaths.dselect(entry, '/gd$name/gd$familyName/$t/*')
        contact['full_name'] = Dpaths.dselect(entry, '/gd$name/gd$fullName/$t/*')

        Array.wrap(entry['gd$email']).each do |email|
          type = email['rel'].split('#').last
          (contact["#{type}_emails"] ||= []) << email['address']
        end

        Array.wrap(entry['gd$im']).each do |im|
          type = im['rel'].split('#').last
          (contact["#{type}_ims"] ||= []) << im['address']
        end

        Array.wrap(entry['gd$phoneNumber']).each do |phone|
          type = phone['rel'].present? ? phone['rel'].split('#').last : phone['label']
          (contact["#{type}_phone_numbers"] ||= []) << phone['$t'].strip
        end

        Array.wrap(entry['gd$structuredPostalAddress']).each do |addr|
          type = addr['rel'].present? ? addr['rel'].split('#').last : addr['label']
          (contact["#{type}_addresses"] ||= []) << simplified_address = {}
          simplified_address["street"] = Dpaths.dselect(addr, '/gd$street/$t/*')
          simplified_address["city"] = Dpaths.dselect(addr, '/gd$city/$t/*')
          simplified_address["region"] = Dpaths.dselect(addr, '/gd$region/$t/*')
          simplified_address["postcode"] = Dpaths.dselect(addr, '/gd$postcode/$t/*')
          simplified_address["country"] = Dpaths.dselect(addr, '/gd$country/$t/*')
        end
      end
    end
  end

  def request(method, path=nil, headers: {}, query: {}, body: {})
    url = "https://www.google.com/m8/feeds/contacts/default/full#{ "/#{path}" if path }"
    rsp = http(method, url,
      :query   => query.merge( 'alt' => 'json'),
      :body    => body,
      :headers => headers.merge(
        'Authorization' => "Bearer #{token}",
        'GData-Version' => '3.0'
      )
    )

    if rsp.code.in? [200]
      simplify_contact(rsp['feed']['entry'])
    end
  end

  def check_authorization
    # user accepting oauth2 offline request is enough to verify authorization
    true
  end

  def request_page(page, limit, query)
    query.merge!(
      'max-results' => limit,
      'start-index' => offset_for_page(page: page, limit: limit),
    )
    request(:get, nil, query: query)
  end

  def read_contact(identifier)
    request(:get, identifier)
  end

  def updated_contacts(updated_since: 1.week.ago, limit: 250, page: 1)
    request_page(page, limit, 'updated-min' => updated_since.utc.strftime('%FT%T'))
  end

  def created_contacts(created_since: 1.week.ago, limit: 250, page: 1)
    request_page(page, limit, 'created-min' => created_since.utc.strftime('%FT%T'))
  end

  def search_contacts(emails)
    email_address = emails.values.first.first
    request(:get, nil, query: { q: email_address })
  end
end
