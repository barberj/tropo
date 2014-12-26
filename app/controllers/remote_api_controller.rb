class RemoteApiController < ApplicationController
  def new; end

  def signup
    session['token'] = params['token']
    redirect_to url_for(controller: params['controller'], action: :new)
  end
end
