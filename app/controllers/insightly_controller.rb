class InsightlyController < ApiController
  def create
    api = Insightly.create(
      token: session['token'],
      data: { api_key: params['key'] }
    )
    if !api.valid?
      redirect_to :back
    else
      redirect_to session['redirect_uri']
    end
  end
end
