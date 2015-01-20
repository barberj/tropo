require 'rails_helper'

describe 'Request' do
  context 'with no Authorization Header' do
    it 'get returns unauthorized (401)' do
      expect(get('/contacts')).to eq 401
    end
    it 'post returns unauthorized (401)' do
      expect(post('/contacts')).to eq 401
    end
    it 'put returns unauthorized (401)' do
      expect(put('/contacts')).to eq 401
    end
    it 'delete returns unauthorized (401)' do
      expect(delete('/contacts')).to eq 401
    end
  end

  context 'with bad Authorization Header' do
    context 'get' do
      it 'returns unauthorized (401)' do
        expect(get('/contacts',
          'HTTP_AUTHORIZATION' => "Token bad_token"
        )).to eq 401
      end
      it 'returns unauthorized message' do
        get('/contacts',
          'HTTP_AUTHORIZATION' => "Token bad_token"
        )

        expect(json['message']).to eq(
          'Unauthorized. Please ensure Api is authorized and retry.'
        )
      end
    end
    it 'post returns unauthorized (401)' do
      expect(post('/contacts',
        'HTTP_AUTHORIZATION' => "Token bad_token"
      )).to eq 401
    end
    it 'put returns unauthorized (401)' do
      expect(put('/contacts',
        'HTTP_AUTHORIZATION' => "Token bad_token"
      )).to eq 401
    end
    it 'delete returns unauthorized (401)' do
      expect(delete('/contacts',
        'HTTP_AUTHORIZATION' => "Token bad_token"
      )).to eq 401
    end
  end
end
