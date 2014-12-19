class Insightly < Api
  def request(method, resource, params={})
    http(method, "https://api.insight.ly/v2.1/#{resource}",
      query: params,
      basic_auth: { username: data[:api_key] }
    )
  end
end
