require 'rails_helper'

describe 'PostRequests' do
  context 'for Api with action' do
    before do
      expect_any_instance_of(Api).to receive(:authorized?).and_return(true)
      create(:api, :data => {:api_key => 'letmein'})
    end
    context 'when errors'
    context 'when missing data' do
      it 'returns bad_request (400)' do
        rsp = post(
          api_v1_path('contacts'),
          nil,
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )

        expect(rsp).to eq 400
      end
      it 'returns missing data message' do
        post(
          api_v1_path('contacts'),
          nil,
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )

        expect(json['message']).to eq(
          'Post Requests must include data.'
        )
      end
    end
  end
  context 'for Api without action'
end
