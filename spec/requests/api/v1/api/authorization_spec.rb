require 'rails_helper'

describe 'Api Request' do
  context 'with no Authorization Header' do
    it 'get returns 401' do
      expect(get(api_v1_path('contacts'))).to eq 401
    end
    it 'post returns 401' do
      expect(post(api_v1_path('contacts'))).to eq 401
    end
    it 'put returns 401' do
      expect(put(api_v1_path('contacts'))).to eq 401
    end
    it 'delete returns 401' do
      expect(delete(api_v1_path('contacts'))).to eq 401
    end
  end

  context 'with bad Authorization Header' do
    it 'get returns 401' do
      expect(get(api_v1_path('contacts'),
        'HTTP_AUTHORIZATION' => "Token bad_token"
      )).to eq 401
    end
    it 'post returns 401' do
      expect(post(api_v1_path('contacts'),
        'HTTP_AUTHORIZATION' => "Token bad_token"
      )).to eq 401
    end
    it 'put returns 401' do
      expect(put(api_v1_path('contacts'),
        'HTTP_AUTHORIZATION' => "Token bad_token"
      )).to eq 401
    end
    it 'delete returns 401' do
      expect(delete(api_v1_path('contacts'),
        'HTTP_AUTHORIZATION' => "Token bad_token"
      )).to eq 401
    end
  end
end
