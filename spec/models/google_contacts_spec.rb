require 'rails_helper'

describe GoogleContacts do
  before do
    expect_any_instance_of(Api).to receive(:authorized?).and_return(true)
  end
  let!(:api) do
    id = create(:api,
      :type => 'GoogleContacts',
      :data => {:api_key => 'letmein'}
    ).id
    Api.find(id)
  end
  context 'with access token' do
    before do
      expect(api).to receive(:refresh_token).and_return('token')
    end
    describe '#check_authorization' do
      it 'returns contacts' do
        stub_request(:get, "https://www.google.com/m8/feeds/contacts/default/full/").
          with(:query => {'alt' => 'json'},
            :headers => {
              'Authorization' => "Bearer token",
              'GData-Version' => '3.0'
            }
          ).to_return(File.new("#{mock_base}/contacts.txt"))

        expect(api.check_authorization).to be_present
      end
    end
  end
end
