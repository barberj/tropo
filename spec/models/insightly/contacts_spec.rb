require 'rails_helper'

describe Insightly do
  let!(:api) do
    id = create(:api, :data => {:api_key => 'letmein'}).id
    Api.find(id)
  end

  let(:mock_base) { 'spec/webmocks/insightly' }

  describe '#request' do
    it 'includes basic authorization' do
      stub = stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/basic_auth')
        .to_return(:status => 200, :body => "", :headers => {})

      api.request(:get, 'basic_auth')
      expect(stub).to have_been_requested
    end
  end

  describe 'search' do
    let(:stub_search_contacts) do
      stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/Contacts')
        .with(:query => {
          'email' => "alice@barberfami.ly",
        })
    end

    it 'returns contacts' do
      stub_search_contacts
        .to_return(File.new("#{mock_base}/a_contact.txt"))

      contacts = api.search_contacts(email: 'alice@barberfami.ly')
      info = contacts.first['CONTACTINFOS'].first
      expect(info['DETAIL']).to eq "wade@zapier.com"
    end
    it 'returns empty' do
      stub_search_contacts
        .to_return(File.new("#{mock_base}/nothing.txt"))

      expect(api.search_contacts(email: 'alice@barberfami.ly'))
        .to be_empty
    end
    it 'raises unauthorized' do
      stub_search_contacts
        .to_return(File.new("#{mock_base}/unauthorized.txt"))

      expect{api.search_contacts(email: 'alice@barberfami.ly')}
        .to raise_error Exceptions::Unauthorized
    end
  end

  describe 'created' do
    let(:stub_created_contacts) do
      stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/Contacts')
        .with(:query => {
          '$filter' => "DATE_CREATED_UTC gt DateTime'2014-12-19T16:16:00'",
          '$skip'   => '0',
          '$top'    => '250'
        })
    end

    it 'returns contacts' do
      stub_created_contacts
        .to_return(File.new("#{mock_base}/a_contact.txt"))

      contacts = api.created_contacts(
        created_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
      )

      expect(contacts.first['CONTACT_ID']).to eq 91978560
    end
    it 'returns empty' do
      stub_created_contacts
        .to_return(File.new("#{mock_base}/nothing.txt"))

      contacts = api.created_contacts(
        created_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
      )

      expect(contacts).to be_empty
    end
    it 'raises unauthorized' do
      stub_created_contacts
        .to_return(File.new("#{mock_base}/unauthorized.txt"))

      expect{api.created_contacts(
        created_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
      )}.to raise_error Exceptions::Unauthorized
    end
  end

  describe 'updated' do
    let(:stub_updated_contacts) do
      stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/Contacts')
        .with(:query => {
          '$filter' => "DATE_UPDATED_UTC gt DateTime'2014-12-19T16:16:00'",
          '$skip'   => '0',
          '$top'    => '250'
        })
    end

    it 'returns contacts' do
      stub_updated_contacts
        .to_return(File.new("#{mock_base}/a_contact.txt"))

      contacts = api.updated_contacts(
        updated_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
      )

      expect(contacts.first['CONTACT_ID']).to eq 91978560
    end
    it 'returns empty' do
      stub_updated_contacts
        .to_return(File.new("#{mock_base}/nothing.txt"))

      contacts = api.updated_contacts(
        updated_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
      )

      expect(contacts).to be_empty
    end
    it 'raises unauthorized' do
      stub_updated_contacts
        .to_return(File.new("#{mock_base}/unauthorized.txt"))

      expect{api.updated_contacts(
        updated_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
      )}.to raise_error Exceptions::Unauthorized
    end
  end
end
