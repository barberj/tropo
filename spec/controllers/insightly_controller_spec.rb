require 'rails_helper'

describe InsightlyController do

  context '#signup' do
    it 'puts token into session' do
      expect{
        post :signup, { 'token' => 'insightly_token' }
      }.to change {
        session['token']
      }.to eq 'insightly_token'
    end

    it 'redirects to new' do
      post :signup, { 'token' => 'insightly_token' }
      expect(response).to redirect_to(new_insightly_path)
    end
  end
end
