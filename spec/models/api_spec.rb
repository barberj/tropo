require 'rails_helper'

describe Api do
  let(:insightly) do
    Api.find(create(:api).id)
  end

  describe '#name' do
    it 'defaults to type' do
      expect(insightly.name).to eq('Insightly')
    end
  end
end
