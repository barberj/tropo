class InsightlyController < RemoteApiController
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
