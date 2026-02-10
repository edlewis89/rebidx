module Api
  class SessionsController < Devise::SessionsController
    skip_before_action :verify_authenticity_token, only: [:create]
    respond_to :json

    def create
      user = User.find_for_database_authentication(email: params[:user][:email])
      if user&.valid_password?(params[:user][:password])
        sign_in(user)
        render json: { user: user, token: Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first }
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end
  end
end