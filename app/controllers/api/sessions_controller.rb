module Api
  class SessionsController < Api::BaseController
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