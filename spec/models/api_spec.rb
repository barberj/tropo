require 'rails_helper'

describe Api do
  let(:insightly) do
    Api.find_by_type('Insightly')
  end

  describe '#name' do
    it 'defaults to type' do
      binding.pry
      expect(insightly.name).to eq('Insightly')
    end
  end
end
