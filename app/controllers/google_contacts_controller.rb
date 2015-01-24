class GoogleContactsController < ApiController
  def new
    super

    oauth = {
      client_id: '1026077737604-j4tu3ov7qer2e81b1h7keejb25sebng5.apps.googleusercontent.com',
      redirect_uri: 'http://localhost:3001/google_contacts/confirm',
      scope: 'https://www.google.com/m8/feeds',
      response_type: 'code',
      access_type: 'offline',
      approval_prompt: "force"
    }

    redirect_to "https://accounts.google.com/o/oauth2/auth?#{oauth.to_query}"
  end

  def create
    if params['code']
      rsp = Requests.http(:post, "https://accounts.google.com/o/oauth2/token",
        body: {
          client_id: "1026077737604-j4tu3ov7qer2e81b1h7keejb25sebng5.apps.googleusercontent.com",
          client_secret: "IJLxxyYUTO0mtI3l_5Q5E36A",
          code: params['code'],
          grant_type: "authorization_code",
          redirect_uri: "http://localhost:3001/google_contacts/confirm"
        }
      )

      GoogleContacts.create(
        token: session['token'],
        data: rsp
      )
    end

    redirect_to session['redirect_uri']
  end
end
