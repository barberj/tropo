require 'rails_helper'

describe 'GetRequest' do
  before do
    expect_any_instance_of(Api).to receive(:authorized?).and_return(true)
    create(:api, :data => {:api_key => 'letmein'})
  end

  context 'for Api with action' do
    context 'when missing params' do
      it 'returns bad_request (400)' do
        rsp = get(
          api_v1_path('contacts'),
          nil,
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )

        expect(rsp).to eq 400
      end
      it 'returns missing params message' do
        get(
          api_v1_path('contacts'),
          nil,
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )

        expect(json['message']).to eq(
          'Get Requests Params must include either created_since, updated_since, identifiers, or search_by.'
        )
      end
    end
    context 'when unauthorized' do
      it 'returns unauthorized (401)' do
        expect_any_instance_of(Insightly)
          .to receive(:created_contacts)
          .and_raise Exceptions::Unauthorized

        rsp = get(
          api_v1_path('contacts'),
          { :created_since => Time.new(2014, 12, 29, 0, 0, 0, 0) },
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )
        expect(rsp).to eq 401
      end

      it 'returns unsupported action message' do
        expect_any_instance_of(Insightly)
          .to receive(:created_contacts)
          .and_raise Exceptions::Unauthorized

        get(
          api_v1_path('contacts'),
          { :created_since => Time.new(2014, 12, 29, 0, 0, 0, 0) },
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )

        expect(json['message']).to match(
          /is not authorized. Please fix your authorization on \w+ and then retry./
        )
      end
    end
    context 'with created_since params' do
      it 'calls created_resource' do
        expect_any_instance_of(Insightly)
          .to receive(:created_contacts)

        get(
          api_v1_path('contacts'),
          { :created_since => Time.new(2014, 12, 29, 0, 0, 0, 0).strftime('%FT%T') },
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )
      end
    end
    context 'with updated_since params' do
      it 'calls updated_resource' do
        expect_any_instance_of(Insightly)
          .to receive(:updated_contacts)

        get(
          api_v1_path('contacts'),
          { :updated_since => Time.new(2014, 12, 29, 0, 0, 0, 0).strftime('%FT%T') },
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )
      end
    end
    context 'with identifier params' do
      it 'calls search_resource' do
        expect_any_instance_of(Insightly)
          .to receive(:read_contacts)

        get(
          api_v1_path('contacts'),
          { :identifiers => ['1'] },
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )
      end
    end
    context 'with search_by params' do
      it 'calls search_resource' do
        expect_any_instance_of(Insightly)
          .to receive(:search_contacts)

        get(
          api_v1_path('contacts'),
          { :search_by => { :email => 'barber.justin@gmail.com' }},
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )
      end
    end
  end
  context 'for Api without action' do
    context 'with created_since params' do
      it 'returns unprocessable_entity (422)'
    end
    context 'with updated_since params' do
      it 'returns unprocessable_entity (422)'
    end
    context 'with identifier params' do
      it 'returns unprocessable_entity (422)'
    end
    context 'with search_by params' do
      it 'returns unprocessable_entity (422)'
    end
  end
end
