require 'rails_helper'

describe GoogleContacts do
  before do
    expect_any_instance_of(Api).to receive(:authorized?).and_return(true)
    expect(api).to receive(:refresh_token).and_return('token')
  end
  let!(:api) do
    id = create(:api,
      :type => 'GoogleContacts',
      :data => {:api_key => 'letmein'}
    ).id
    Api.find(id)
  end

  describe 'contact' do
    describe 'read' do
      let(:stub_read_contact) do
        stub_request(:get, 'https://www.google.com/m8/feeds/contacts/default/full/1').
          with(
            :query => {
              'alt' => "json"
            },
            :headers => {
              'Authorization' => "Bearer token",
              'GData-Version' => '3.0'
            }
          )
      end
      it 'returns contact' do
        stub_read_contact.
          to_return(File.new("#{mock_base}/contact.txt"))

        expect(api.read_contact(1).first).to include('id' => '30b75c0e8a26b6b7')
      end
      it 'returns empty' do
        stub_read_contact.
          to_return(File.new("#{mock_base}/no_contacts.txt"))

        expect(api.read_contact(1)).to be_empty
      end
      it 'returns simplified contact info' do
        stub_read_contact.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        contact = api.read_contact(1).first
        expect(contact).to include(
          'title'           => 'pre first middle last suff',
          'content'         => 'note',
          'given_name'      => 'first',
          'family_name'     => 'last',
          'additional_name' => 'middle',
          'nickname'        => 'nickname',
          'org_name'        => 'company',
          'org_title'       => 'title'
        )
      end
      it 'returns simplified contact emails' do
        stub_read_contact.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        contact = api.read_contact(1).first
        expect(contact['work_emails']).to eq(['work'])
        expect(contact['home_emails']).to eq(['home'])
      end
      it 'returns simplified address' do
        stub_read_contact.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        contact = api.read_contact(1).first
        expect(contact['work_addresses'].count).to eq(1)
        expect(contact['work_addresses'].first).to include(
          'street'   => 'street',
          'city'     => 'city',
          'region'   => 'state',
          'postcode' => 'zip',
          'country'  => 'country'
        )
      end
    end
    describe 'updated' do
      let(:stub_updated_contacts) do
        stub_request(:get, 'https://www.google.com/m8/feeds/contacts/default/full').
          with(
            :query => {
              'alt'         => "json",
              'start-index' => 0,
              'max-results' => 250,
              'updated-min' => '2015-02-03T00:00:00'
            },
            :headers => {
              'Authorization' => "Bearer token",
              'GData-Version' => '3.0'
            }
          )
      end
      it 'returns contacts' do
        stub_updated_contacts.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        expect(api.updated_contacts(
          updated_since: Time.new(2015, 2, 3, 0, 0, 0, 0)
        ).first).to include('id' => '30b75c0e8a26b6b7')
      end
      it 'returns empty' do
        stub_updated_contacts.
          to_return(File.new("#{mock_base}/no_contacts.txt"))

        expect(api.updated_contacts(
          updated_since: Time.new(2015, 2, 3, 0, 0, 0, 0)
        )).to be_empty
      end
      it 'pages' do
        stub_request(:get, 'https://www.google.com/m8/feeds/contacts/default/full').
          with(
            :query => {
              'alt'         => "json",
              'start-index' => 250,
              'max-results' => 250,
              'updated-min' => '2015-02-03T00:00:00'
            },
            :headers => {
              'Authorization' => "Bearer token",
              'GData-Version' => '3.0'
            }
          ).
          to_return(File.new("#{mock_base}/a_contact.txt"))

        expect(api.updated_contacts(
          updated_since: Time.new(2015, 2, 3, 0, 0, 0, 0),
          page: 2
        ).first).to include('id' => '30b75c0e8a26b6b7')
      end
      it 'limits' do
        stub_request(:get, 'https://www.google.com/m8/feeds/contacts/default/full').
          with(
            :query => {
              'alt'         => "json",
              'start-index' => 10,
              'max-results' => 10,
              'updated-min' => '2015-02-03T00:00:00'
            },
            :headers => {
              'Authorization' => "Bearer token",
              'GData-Version' => '3.0'
            }
          ).
          to_return(File.new("#{mock_base}/a_contact.txt"))

        expect(api.updated_contacts(
          updated_since: Time.new(2015, 2, 3, 0, 0, 0, 0),
          page: 2,
          limit: 10
        ).first).to include('id' => '30b75c0e8a26b6b7')
      end
      it 'returns simplified contact info' do
        stub_updated_contacts.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        contact = api.updated_contacts(
          updated_since: Time.new(2015, 2, 3, 0, 0, 0, 0),
        ).first

        expect(contact).to include(
          'title'           => 'pre first middle last suff',
          'content'         => 'note',
          'given_name'      => 'first',
          'family_name'     => 'last',
          'additional_name' => 'middle',
          'nickname'        => 'nickname',
          'org_name'        => 'company',
          'org_title'       => 'title'
        )
      end
    end
    describe 'created' do
      let(:stub_created_contacts) do
        stub_request(:get, 'https://www.google.com/m8/feeds/contacts/default/full').
          with(
            :query => {
              'alt'         => "json",
              'start-index' => 0,
              'max-results' => 250,
              'created-min' => '2015-02-03T00:00:00'
            },
            :headers => {
              'Authorization' => "Bearer token",
              'GData-Version' => '3.0'
            }
          )
      end
      it 'returns contacts' do
        stub_created_contacts.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        expect(api.created_contacts(
          created_since: Time.new(2015, 2, 3, 0, 0, 0, 0)
        ).first).to include('id' => '30b75c0e8a26b6b7')
      end
      it 'returns empty' do
        stub_created_contacts.
          to_return(File.new("#{mock_base}/no_contacts.txt"))

        expect(api.created_contacts(
          created_since: Time.new(2015, 2, 3, 0, 0, 0, 0)
        )).to be_empty
      end
    end
    describe 'search' do
      let(:stub_search_contacts) do
        stub_request(:get, 'https://www.google.com/m8/feeds/contacts/default/full').
          with(
            :query => {
              'q'   => 'alice@barberfami.ly',
              'alt' => "json",
            },
            :headers => {
              'Authorization' => "Bearer token",
              'GData-Version' => '3.0'
            }
          )
      end
      it 'returns empty' do
        stub_search_contacts.
          to_return(File.new("#{mock_base}/no_contacts.txt"))

        expect(api.search_contacts(
          work_emails: ['alice@barberfami.ly']
        )).to be_empty
      end
      it 'returns contacts' do
        stub_search_contacts.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        expect(api.search_contacts(
          work_emails: ['alice@barberfami.ly']
        ).first).to include('id' => '30b75c0e8a26b6b7')
      end
      it 'returns simplified contact info' do
        stub_search_contacts.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        contact = api.search_contacts(
          home_emails: ['alice@barberfami.ly']
        ).first

        expect(contact).to include(
          'title'       => 'pre first middle last suff',
          'content'     => 'note',
          'given_name'  => 'first',
          'family_name' => 'last'
        )
      end
    end
    describe 'create' do
      it 'returns contact' do
        contact = api.create_contact('given_name' => 'Justin').first
        expect(contact['id']).to eq('50455d538eae9940')
      end
    end
    describe 'update'
    describe 'delete' do
      let(:stub_delete_contact) do
        stub_request(:delete, 'https://www.google.com/m8/feeds/contacts/default/full/12345').
          with(
            :query => {
              'alt' => "json",
            },
            :headers => {
              'Authorization' => "Bearer token",
              'GData-Version' => '3.0',
              'If-Match'      => '*'
            }
          )
      end
      it 'returns accepted' do
        stub_delete_contact.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        expect(api.delete_contact(12345).first).
          to include('id' => '30b75c0e8a26b6b7')
      end
      it 'raises ApiError' do
        stub_delete_contact.
          to_return(File.new("#{mock_base}/not_found.txt"))

        expect{api.delete_contact(12345)}.
          to raise_error Exceptions::ApiError
      end
      it 'returns api message' do
        stub_delete_contact.
          to_return(File.new("#{mock_base}/not_found.txt"))

        expect{api.delete_contact(12345)}.
          to raise_error(/Contact not found/)
      end
    end
  end
end
