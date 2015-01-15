class InsightlyController < ApiController
  def create
    api = Insightly.create(
      token: session['token'],
      data: { api_key: params['key'] }
    )
    if !api.valid?
      redirect_to :back
    else
      redirect_to 'http://127.0.0.1:3000/dashboard'
    end
  end
end
