require 'rails_helper'

describe Api do
  let(:insightly) do
    Api.find_by_type('insightly')
  end
  describe '#name' do
    binding.pry
    expect(insightly.name).to eq('Insightly')
  end
end
