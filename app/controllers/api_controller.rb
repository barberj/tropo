class ApiController < ApplicationController
  def new; end

  def signup
    session[:token] = params['token']
    session[:redirect_uri] = params['redirect_uri']
    redirect_to url_for(controller: params['controller'], action: :new)
  end
end
