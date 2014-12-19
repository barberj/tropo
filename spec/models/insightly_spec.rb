require 'rails_helper'

describe Insightly do
  let!(:insightly) do
    id = create(:api, :data => {:api_key => 'letmein'}).id
    Api.find(id)
  end

  it '#name defaults to type' do
    expect(insightly.name).to eq('Insightly')
  end

  it '#find_by_token' do
    expect(Api.find_by_token('insightly_token')).to eq(insightly)
  end

  describe '.encrypted_data' do
    it '#data returns decrypted client data' do
      expect(insightly.data[:api_key]).to eq('letmein')
    end
    it '#data! updates encrypted client data' do
      insightly.data!(key_two: 'two')

      expect(insightly.data[:key_two]).to eq('two')
      expect(insightly.data[:api_key]).to eq('letmein')
    end
    it '#data sets encrypted client data' do
      insightly.data= {key_two: 'two'}

      expect(insightly.data[:key_two]).to eq('two')
      expect(insightly.data[:api_key]).to be_nil
    end
  end
end
