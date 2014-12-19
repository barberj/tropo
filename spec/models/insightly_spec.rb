require 'rails_helper'

describe Insightly do
  let!(:api) do
    id = create(:api, :data => {:api_key => 'letmein'}).id
    Api.find(id)
  end

  describe '#request' do
    it 'includes base64 authorization header' do
      stub = stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/header_test')
        .to_return(:status => 200, :body => "", :headers => {})

      api.request(:get, 'header_test')
      expect(stub).to have_been_requested
    end
  end
end
