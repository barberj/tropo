require 'rails_helper'

describe 'Api Request' do
  context 'with no Authorization Header' do
    it 'get returns 401' do
      expect(get("/api/v1/contacts'")).to eq 401
    end
    it 'post returns 401' do
      expect(post("/api/v1/contacts'")).to eq 401
    end
    it 'put returns 401' do
      expect(put("/api/v1/contacts'")).to eq 401
    end
    it 'delete returns 401' do
      expect(delete("/api/v1/contacts'")).to eq 401
    end
  end

  context 'with bad Authorization Header' do
    it 'get returns 401' do
      expect(get("/api/v1/contacts'",
        'HTTP_AUTHORIZATION' => "Token bad_token"
      )).to eq 401
    end
    it 'post returns 401' do
      expect(post("/api/v1/contacts",
        'HTTP_AUTHORIZATION' => "Token bad_token"
      )).to eq 401
    end
    it 'put returns 401' do
      expect(put("/api/v1/contacts",
        'HTTP_AUTHORIZATION' => "Token bad_token"
      )).to eq 401
    end
    it 'delete returns 401' do
      expect(delete("/api/v1/contacts",
        'HTTP_AUTHORIZATION' => "Token bad_token"
      )).to eq 401
    end
  end
end
