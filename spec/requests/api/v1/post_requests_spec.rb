require 'rails_helper'

describe 'PostRequests' do
  context 'for Api with action' do
    let(:data) do
      {
        data: [ {'FIRST_NAME' => 'Justin'} ]
      }
    end
    let(:post_request) do
      post(
        api_v1_path('contacts'),
        data,
        'HTTP_AUTHORIZATION' => "Token insightly_token"
      )
    end

    before do
      expect_any_instance_of(Api).to receive(:authorized?).and_return(true)
      create(:api, :data => {:api_key => 'letmein'})
    end
    context 'when missing data' do
      let(:post_request) do
        post(
          api_v1_path('contacts'),
          nil,
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )
      end

      it 'returns bad_request (400)' do
        expect(post_request).to eq 400
      end
      it 'returns missing data message' do
        post_request

        expect(json['message']).to eq(
          'Post Requests must include data.'
        )
      end
    end
    context 'when unauthorized' do
      before do
        expect_any_instance_of(Insightly)
          .to receive(:create_contact)
          .and_raise Exceptions::Unauthorized
      end
      it 'returns unauthorized (401)' do
        expect(post_request).to eq 401
      end

      it 'returns unauthorized message' do
        post_request

        expect(json['message']).to match(
          /is not authorized. Please fix your authorization on \w+ and then retry./
        )
      end
    end
    context 'when creates one' do
      it 'calls create_resource' do
        expect_any_instance_of(Insightly)
          .to receive(:create_contact)

        post_request
      end
      it 'returns ok (200)' do
        expect_any_instance_of(Insightly)
          .to receive(:create_contact)

        expect(post_request).to eq(200)
      end
      it 'returns results' do
        expect_any_instance_of(Insightly)
          .to receive(:create_contact)
          .and_return([1])

        post_request

        expect(json['results']).to eq([1])
      end
      it 'iterates for multiple datasets' do
        data[:data] << {'FIRST_NAME' => 'Robby'}
        expect_any_instance_of(Insightly)
          .to receive(:create_contact).twice

        expect(post_request).to eq(200)
      end
    end
  end
  context 'for Api without action'
end
