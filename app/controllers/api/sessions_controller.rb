module Api
  class SessionsController < Api::BaseController
    # Skip token authentication for login
    skip_before_action :authenticate_request, only: [:create]
    def create
      user = User.find_for_database_authentication(email: params[:user][:email])

      if user&.valid_password?(params[:user][:password])
        token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)

        render json: {
          user: user,
          token: token
        }
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end
  end
end