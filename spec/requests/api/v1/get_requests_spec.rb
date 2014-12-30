require 'rails_helper'

describe 'GetRequest' do
  before do
    expect_any_instance_of(Api).to receive(:authorized?).and_return(true)
    create(:api, :data => {:api_key => 'letmein'})
  end

  context 'for Api with action' do
    context 'with created_since params' do
      it 'calls created_resource' do
        expect_any_instance_of(Insightly)
          .to receive(:created_contacts)

        get(
          api_v1_path('contacts'),
          { :created_since => Time.new(2014, 12, 29, 0, 0, 0, 0).strftime('%FT%T') },
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )
      end
    end
    context 'with updated_since params' do
      it 'calls updated_resource' do
        expect_any_instance_of(Insightly)
          .to receive(:updated_contacts)

        get(
          api_v1_path('contacts'),
          { :updated_since => Time.new(2014, 12, 29, 0, 0, 0, 0).strftime('%FT%T') },
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )
      end
    end
    context 'with identifier params' do
      it 'calls search_resource' do
        expect_any_instance_of(Insightly)
          .to receive(:read_contacts)

        get(
          api_v1_path('contacts'),
          { :identifiers => ['1'] },
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )
      end
    end
    context 'with search_by params' do
      it 'calls search_resource' do
        expect_any_instance_of(Insightly)
          .to receive(:search_contacts)

        get(
          api_v1_path('contacts'),
          { :search_by => { :email => 'barber.justin@gmail.com' }},
          'HTTP_AUTHORIZATION' => "Token insightly_token"
        )
      end
    end
  end
  context 'for Api without action' do
    context 'with created_since params' do
      it 'returns unprocessable_entity (422)'
    end
    context 'with updated_since params' do
      it 'returns unprocessable_entity (422)'
    end
    context 'with identifier params' do
      it 'returns unprocessable_entity (422)'
    end
    context 'with search_by params' do
      it 'returns unprocessable_entity (422)'
    end
  end
end
