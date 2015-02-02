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
          to_return(File.new("#{mock_base}/a_contact.txt"))

        expect(api.read_contact(1).first).to include('id' => '7f7b814a8c299763')
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
          'title'       => 'Elizabeth Bennet',
          'content'     => 'Notes',
          'given_name'  => 'Elizabeth',
          'family_name' => 'Bennet'
        )
      end
      it 'returns simplified contact emails' do
        stub_read_contact.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        contact = api.read_contact(1).first
        expect(contact['work_emails']).to eq(['liz@gmail.com'])
        expect(contact['home_emails']).to eq(['liz@example.org'])
      end
      it 'returns simplified address' do
        stub_read_contact.
          to_return(File.new("#{mock_base}/a_contact.txt"))

        contact = api.read_contact(1).first
        expect(contact['work_addresses'].count).to eq(1)
        expect(contact['work_addresses'].first).to include(
          'street'   => '1600 Amphitheatre Pkwy',
          'city'     => 'Mountain View',
          'region'   => 'CA',
          'postcode' => '94043',
          'country'  => 'United States'
        )
      end
    end
    describe 'updated'
    describe 'created'
    describe 'search'
    describe 'create'
    describe 'update'
    describe 'delete'
  end
end
