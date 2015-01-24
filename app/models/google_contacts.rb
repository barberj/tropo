class GoogleContacts < Api

  def refresh_token
    @token = HTTParty.post("https://accounts.google.com/o/oauth2/token",
      :body => {
        "client_id"=>"1026077737604-j4tu3ov7qer2e81b1h7keejb25sebng5.apps.googleusercontent.com",
        "client_secret"=>"IJLxxyYUTO0mtI3l_5Q5E36A",
        'refresh_token'=> self.data['refresh_token'],
        "grant_type"=>"refresh_token"
      }
    )['access_token']
  end

  def token
    @token || refresh_token
  end

  def request(method, path=nil, headers: {}, query: {}, body: {})
    http(method, "https://www.google.com/m8/feeds/contacts/default/full/#{path}",
      :query   => query.merge( 'alt' => 'json'),
      :body    => body,
      :headers => headers.merge(
        'Authorization' => "Bearer #{token}",
        'GData-Version' => '3.0'
      )
    )
  end

  def check_authorization
    request(:get)
  end

  def request_page(page, limit, query)
    query.merge(
      'max-results' => limit,
      'start-index' => offset_for_page(page: page, limit: limit),
    )
    request(:get, nil, query: query)
  end

  def read_contact(identifier)
    request(:get, "/#{identifier}")
  end

  def updated_contacts(updated_since: 1.week.ago, limit: 250, page: 1)
    request_page(page, limit, 'updated-min' => updated_since.utc.strftime('%FT%T'))
  end

  def created_contacts(created_since: 1.week.ago, limit: 250, page: 1)
    request_page(page, limit, 'created-min' => created_since.utc.strftime('%FT%T'))
  end
end
