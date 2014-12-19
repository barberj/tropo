module Requests

  def http(method, url, options)
    Requests.http(method, url, options)
  end

  def self.http_client
    HTTParty
  end

  def self.http(method, url, options)
    http_client.send(method, url, options)
  end
end
