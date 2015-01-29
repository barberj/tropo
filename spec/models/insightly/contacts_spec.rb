require 'rails_helper'

describe Insightly do
  before do
    expect_any_instance_of(Api).to receive(:authorized?).and_return(true)
  end
  let!(:api) do
    id = create(:api, :data => {:api_key => 'letmein'}).id
    Api.find(id)
  end
  let(:stub_read_contacts) do
    stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/Contacts').
      with(:query => {
        'ids' => "1,2"
      })
  end

  describe '#request' do
    it 'includes basic authorization' do
      stub = stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/basic_auth').
        to_return(:status => 200, :body => "", :headers => {})

      api.request(:get, 'basic_auth')
      expect(stub).to have_been_requested
    end
  end

  describe '#authorized?' do
    before do
      expect(api).to receive(:authorized?).and_call_original
    end
    let(:stub_get_users) do
      stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/Users')
    end
    it 'returns true' do
      stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/Users').
        to_return(File.new("#{mock_base}/a_user.txt"))

      expect(api.authorized?).to be_truthy
    end
    it 'returns false' do
      stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/Users').
        to_return(File.new("#{mock_base}/unauthorized.txt"))

      expect(api.authorized?).to be_falsey
    end
  end

  describe 'contact' do
    describe 'search' do
      let(:stub_search_contacts) do
        stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/Contacts').
          with(:query => {
            'email' => "alice@barberfami.ly",
          })
      end

      it 'returns contacts' do
        stub_search_contacts.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        contacts = api.search_contacts(email: 'alice@barberfami.ly')
        info = contacts.first['CONTACTINFOS'].first
        expect(info['DETAIL']).to eq "coty@ecommhub.com"
      end
      it 'returns empty' do
        stub_search_contacts.
          to_return(File.new("#{mock_base}/nothing.txt"))

        expect(api.search_contacts(email: 'alice@barberfami.ly')).
          to be_empty
      end
      it 'raises unauthorized' do
        stub_search_contacts.
          to_return(File.new("#{mock_base}/unauthorized.txt"))

        expect{api.search_contacts(email: 'alice@barberfami.ly')}.
          to raise_error Exceptions::Unauthorized
      end
    end

    describe 'created' do
      let(:stub_created_contacts) do
        stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/Contacts').
          with(:query => {
            '$filter' => "DATE_CREATED_UTC gt DateTime'2014-12-19T16:16:00'",
            '$skip'   => '0',
            '$top'    => '250'
          })
      end

      it 'returns contacts' do
        stub_created_contacts.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        contacts = api.created_contacts(
          created_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
        )

        expect(contacts.first['CONTACT_ID']).to eq 94941790
      end
      it 'returns empty' do
        stub_created_contacts.
          to_return(File.new("#{mock_base}/nothing.txt"))

        contacts = api.created_contacts(
          created_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
        )

        expect(contacts).to be_empty
      end
      describe 'when it errors' do
        it 'raises unauthorized' do
          stub_created_contacts.
            to_return(File.new("#{mock_base}/unauthorized.txt"))

          expect{api.created_contacts(
            created_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
          )}.to raise_error Exceptions::Unauthorized
        end
        it 'raises ApiError' do
          stub_created_contacts.
            to_return(File.new("#{mock_base}/invalid_uri.txt"))

          expect{api.created_contacts(
            created_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
          )}.to raise_error Exceptions::ApiError
        end
        it 'returns api message' do
          stub_created_contacts.
            to_return(File.new("#{mock_base}/invalid_uri.txt"))

          expect{api.created_contacts(
            created_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
          )}.to raise_error /The query specified/
        end
      end
    end

    describe 'updated' do
      let(:stub_updated_contacts) do
        stub_request(:get, 'https://letmein:@api.insight.ly/v2.1/Contacts').
          with(:query => {
            '$filter' => "DATE_UPDATED_UTC gt DateTime'2014-12-19T16:16:00'",
            '$skip'   => '0',
            '$top'    => '250'
          })
      end

      it 'returns contacts' do
        stub_updated_contacts.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        contacts = api.updated_contacts(
          updated_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
        )

        expect(contacts.first['CONTACT_ID']).to eq 94941790
      end
      it 'returns empty' do
        stub_updated_contacts.
          to_return(File.new("#{mock_base}/nothing.txt"))

        contacts = api.updated_contacts(
          updated_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
        )

        expect(contacts).to be_empty
      end
      it 'raises unauthorized' do
        stub_updated_contacts.
          to_return(File.new("#{mock_base}/unauthorized.txt"))

        expect{api.updated_contacts(
          updated_since: Time.new(2014, 12, 19, 11, 16, 0, -5*3600)
        )}.to raise_error Exceptions::Unauthorized
      end
    end
    describe 'read' do
      it 'returns contacts' do
        stub_read_contacts.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        contacts = api.read_contacts([1,2])

        expect(contacts.first['CONTACT_ID']).to eq 94941790
      end
      it 'returns empty' do
        stub_read_contacts.
          to_return(File.new("#{mock_base}/nothing.txt"))

        contacts = api.read_contacts([1,2])

        expect(contacts).to be_empty
      end
      it 'raises unauthorized' do
        stub_read_contacts.
          to_return(File.new("#{mock_base}/unauthorized.txt"))

        expect{api.read_contacts(
          [1,2]
        )}.to raise_error Exceptions::Unauthorized
      end
    end
    it 'returns simplified address' do
      stub_read_contacts.
        to_return(File.new("#{mock_base}/a_contact.txt"))

      contacts = api.read_contacts([1,2])
      address = contacts.first['WORK_ADDRESSES'].first

      expect(address).to include(
        'ADDRESS_ID'   => 50036173,
        'ADDRESS_TYPE' => 'WORK',
        'STREET'       => '730 Peachtree St., NE Suite 330',
        'CITY'         => 'Atlanta',
        'STATE'        => 'Ga',
        'POSTCODE'     => '30308',
        'COUNTRY'      => 'United States'
      )
    end
    it 'returns simplified phone numbers' do
      stub_read_contacts.
        to_return(File.new("#{mock_base}/a_contact.txt"))

      contacts = api.read_contacts([1,2])
      number = contacts.first['WORK_PHONE_NUMBERS']

      expect(number).to include( "6784625167" )
    end
    it 'returns simplified websites' do
      stub_read_contacts.
        to_return(File.new("#{mock_base}/a_contact.txt"))

      contacts = api.read_contacts([1,2])
      site = contacts.first['WORK_WEBSITES']

      expect(site).to include( "www.ecommhub.com" )
    end
    it 'returns simplified social' do
      stub_read_contacts.
        to_return(File.new("#{mock_base}/a_contact.txt"))

      contacts = api.read_contacts([1,2])
      social = contacts.first['TWITTER']

      expect(social).to include( "eCommHub" )

      social = contacts.first['LINKEDIN']

      expect(social).to include( "https://www.linkedin.com/profile/view?id=14151" )
    end

    describe 'create' do
      let(:stub_create_contact) do
        stub_request(:post, 'https://letmein:@api.insight.ly/v2.1/Contacts').
          with(
            :body => {
              'FIRST_NAME'   => 'Justin',
            }.to_json,
            :headers =>  { 'content-type' => 'application/json' }
          )
      end
      it 'returns contact' do
        stub_create_contact.
          to_return(File.new("#{mock_base}/modified_contact.txt"))

        contact = api.create_contact('FIRST_NAME' => 'Justin').first
        expect(contact['CONTACT_ID']).to eq(94941790)
      end
      describe 'when it errors' do
        it 'raises ApiError' do
          stub_create_contact.
            to_return(File.new("#{mock_base}/invalid_column_insert.txt"))

          expect{
            api.create_contact('FIRST_NAME' => 'Justin')
          }.to raise_error Exceptions::ApiError
        end
        it 'returns api message' do
          stub_create_contact.
            to_return(File.new("#{mock_base}/invalid_column_insert.txt"))

          expect{
            api.create_contact('FIRST_NAME' => 'Justin')
          }.to raise_error /Cannot insert the value NULL into column/
        end
        it 'formats new contact info' do
          stub_request(:post, 'https://letmein:@api.insight.ly/v2.1/Contacts').
            with(
              :body => {
                'FIRST_NAME'   => 'Justin',
                "ADDRESSES" => [{
                  "STREET"       => "730 Peachtree St., NE Suite 330",
                  "CITY"         => "Atlanta",
                  "STATE"        => "Ga",
                  "POSTCODE"     => "30308",
                  "COUNTRY"      => "United States",
                  "ADDRESS_TYPE" => "WORK"
                }],
                'CONTACTINFOS' => [{
                  "TYPE"    => "EMAIL",
                  "LABEL"   => "WORK",
                  "DETAIL"  => "justin@simpleapi.io"
                },{
                  "TYPE"    => "SOCIAL",
                  "SUBTYPE" => "TwitterID",
                  "LABEL"   => "TwitterID",
                  "DETAIL"  => "simpletwitter"
                },{
                  "TYPE"    => "SOCIAL",
                  "SUBTYPE" => "LinkedInPublicProfileUrl",
                  "LABEL"   => "LinkedInPublicProfileUrl",
                  "DETAIL"  => "simplelinkedin"
                }]
              }.to_json,
              :headers =>  { 'content-type' => 'application/json' }
            ).
            to_return(File.new("#{mock_base}/modified_contact.txt"))

          contact = api.create_contact(
            'FIRST_NAME'  => 'Justin',
            "WORK_ADDRESSES"   => [{
              "STREET"   => "730 Peachtree St., NE Suite 330",
              "CITY"     => "Atlanta",
              "STATE"    => "Ga",
              "POSTCODE" => "30308",
              "COUNTRY"  => "United States"
            }],
            'WORK_EMAILS' => ['justin@simpleapi.io'],
            'TWITTER'     => ['simpletwitter'],
            'LINKEDIN'     => ['simplelinkedin']
          ).first
          expect(contact['CONTACT_ID']).to eq(94941790)
        end
      end
    end
    describe 'update' do
      let(:stub_update_contact) do
        stub_request(:put, 'https://letmein:@api.insight.ly/v2.1/Contacts').
          with(
            :body => {
              'CONTACT_ID' => 1,
              'FIRST_NAME' => 'Justin'
            }.to_json,
            :headers =>  { 'content-type' => 'application/json' }
          )
      end
      it 'returns contact' do
        stub_update_contact.
          to_return(File.new("#{mock_base}/modified_contact.txt"))

        contact = api.update_contact(
          'CONTACT_ID' => 1,
          'FIRST_NAME' => 'Justin'
        ).first
        expect(contact['CONTACT_ID']).to eq(94941790)
      end
    end
    describe 'delete' do
      let(:stub_delete_contact) do
        stub_request(:delete, 'https://letmein:@api.insight.ly/v2.1/Contacts/1').
          with(:headers =>  { 'content-type' => 'application/json' })
      end
      it 'returns accepted' do
        stub_delete_contact.
          to_return(File.new("#{mock_base}/deleted.txt"))

        expect(api.delete_contact(1).code).to eq(202)
      end
      it 'raises ApiError' do
        stub_delete_contact.
          to_return(File.new("#{mock_base}/deletion_error.txt"))

        expect{api.delete_contact(1)}.
          to raise_error Exceptions::ApiError
      end
      it 'returns api message' do
        stub_delete_contact.
          to_return(File.new("#{mock_base}/deletion_error.txt"))

        expect{api.delete_contact(1)}.
          to raise_error(/No Contact/)
      end
    end
  end
end
