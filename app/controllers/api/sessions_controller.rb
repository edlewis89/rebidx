module Api
  class SessionsController < Api::BaseController
    # Skip token authentication for login
    skip_before_action :authenticate_request, only: [:create]
    def create
      user = User.find_for_database_authentication(email: params[:user][:email])

      if user&.valid_password?(params[:user][:password])

        # 🔒 block login if verification required
        if FeatureFlags.email_verification_enabled? && !user.confirmed?
          render json: { error: 'You must verify your email before logging in' }, status: :unauthorized
        else
          token, _payload = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)

          render json: {
            user: {
              id: user.id,
              email: user.email,
              role: user.role
            },
            token: token
          }, status: :ok
        end
      else
        render json: { error: 'Invalid email or password' }, status: :unauthorized
      end
    end
  end
end