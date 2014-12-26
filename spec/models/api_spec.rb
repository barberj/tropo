require 'rails_helper'

describe Api do
  before do
    expect_any_instance_of(Api).to receive(:authorized?).and_return(true)
  end
  let!(:api) do
    id = create(:api, :data => {:api_key => 'letmein'}).id
    Api.find(id)
  end

  it '#name defaults to type' do
    expect(api.name).to eq('Insightly')
  end

  it '#find_by_token' do
    expect(Api.find_by_token('insightly_token')).to eq(api)
  end

  describe '.encrypted_data' do
    it '#data returns decrypted client data' do
      expect(api.data[:api_key]).to eq('letmein')
    end
    it '#data! updates encrypted client data' do
      api.data!(key_two: 'two')

      expect(api.data[:key_two]).to eq('two')
      expect(api.data[:api_key]).to eq('letmein')
    end
    it '#data sets encrypted client data' do
      api.data= {key_two: 'two'}

      expect(api.data[:key_two]).to eq('two')
      expect(api.data[:api_key]).to be_nil
    end
  end

  describe '#offset_for_page' do
    it 'returns offset for page 1' do
      expect(api.offset_for_page(:page => 1, :limit => 250)).to eq 0
      expect(api.offset_for_page(:page => 1, :limit => 1)).to eq 0
      expect(api.offset_for_page(:page => 1, :limit => 2)).to eq 0
    end
    it 'returns offset for page 2' do
      expect(api.offset_for_page(:page => 2, :limit => 250)).to eq 250
      expect(api.offset_for_page(:page => 2, :limit => 1)).to eq 1
      expect(api.offset_for_page(:page => 2, :limit => 2)).to eq 2
    end
    it 'returns offset for page 3' do
      expect(api.offset_for_page(:page => 3, :limit => 250)).to eq 500
      expect(api.offset_for_page(:page => 3, :limit => 1)).to eq 2
      expect(api.offset_for_page(:page => 3, :limit => 2)).to eq 4
    end
    it 'returns offset for page 100' do
      expect(api.offset_for_page(:page => 100, :limit => 250)).to eq 24750
      expect(api.offset_for_page(:page => 100, :limit => 1)).to eq 99
      expect(api.offset_for_page(:page => 100, :limit => 2)).to eq 198
    end
  end
end
