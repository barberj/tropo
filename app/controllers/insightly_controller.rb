class InsightlyController < ApplicationController
  def new
  end

  def signup
    session['token'] = params['token']
    redirect_to new_insightly_path
  end

  def create
    api = Insightly.create(
      token: session['token'],
      data: { api_key: params['key'] }
    )
    if api.valid?
      redirect_to '/'
    else
      redirect_to :back
    end
  end
end
