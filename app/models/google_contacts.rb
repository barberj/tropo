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
        contact['name_prefix'] = Dpaths.dselect(entry, '/gd$name/gd$namePrefix/$t/*')
        contact['name_suffix'] = Dpaths.dselect(entry, '/gd$name/gd$nameSuffix/$t/*')
        contact['nickname'] = Dpaths.dselect(entry, '/gd$name/gd$additionalName/$t/*')

        Array.wrap(entry['gd$email']).each do |email|
          type = email['rel'].present? ? email['rel'].split('#').last : email['label']
          (contact["#{type}_emails"] ||= []) << email['address']
        end

        Array.wrap(entry['gd$im']).each do |im|
          type = im['rel'].present? ? im['rel'].split('#').last : im['label']
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
      simplify_contact(rsp['feed'] ? rsp['feed']['entry'] : rsp['entry'])
    else
      raise Exceptions::ApiError.new(rsp['error']['message'])
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

  def delete_contact(identifier)
    request(:delete, identifier, headers: { 'If-Match' => '*' })
  end

  def create_contact(data)
    xml = format_contact(data)
  end

  NAME_FIELDS = ['given_name', 'family_name', 'full_name']
  def gd_name(data)
    name_xml = ""
    (data.keys & NAME_FIELDS).each do |field|
      gd_field = field.camelcase(:lower)
      name_xml << "<gd:#{gd_field}>#{data[field]}</gd:#{gd_field}>"
    end
    "<gd:name>#{name_xml}</gd:name>"
  end

  def gd_emails(data)
  end

  def format_contact(data)
"<atom:entry xmlns:atom='http://www.w3.org/2005/Atom' xmlns:gd='http://schemas.google.com/g/2005'>
  <atom:category scheme='http://schemas.google.com/g/2005#kind' term='http://schemas.google.com/contact/2008#contact' />
  #{gd_name(data)}
  #{gd_content(data)}
  #{gd_emails(data)}
  #{gd_phone_nubmers(data)}
  #{gd_im(data)}
  #{gd_addresses(data)}
</atom:entry>"
  end
end
