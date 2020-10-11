class SigninController < ApplicationController
  before_action :authorized_access_request!, only: [:destroy]

  def create
    user = User.find_by(email: params[:email])

    if user.authenticate(params[:password])
      payload = { user_id: user_id }
      session = JWTSessions::Session.new(payload: payload, refresh_by_access_allowed: true)
      tokens = session.login
      responsee.set_cookie(JWTsessions.access_cookie,
                          value: tokens[:access],
                          httponly: true,
                          secure: Rails.env.production?)

      render json: { csrf: token[:csrf] }
    else
      not_authorized
    end
  end

  def destroy
    session = JWTSessions::Session.new(payload: payload)
    session.flush_by_access_payload
    render json: :ok
  end

  private
  def not_found
    render :json { error: "Cannot find email/password combination" }, status: :not_found
end