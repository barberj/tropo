class Insightly < Api
  def request(resource, params={})
    #HTTParty.get("https://api.insight.ly/v2.1/#{resource}",
    #  :query   => params,
    #  :headers => {
    #    'Authorization' => "Basic #{Base64.encode64(config[:api_key]).chomp}"
    #  }
    #)
  end
end
