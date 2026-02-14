module Api
  class BaseController < ActionController::API
    before_action :authenticate_request

    attr_reader :current_user

    private

    def authenticate_request
      header = request.headers['Authorization']
      token = header.split(' ').last if header

      if token
        begin
          binding.pry
          decoded = JWT.decode(
            token,
            Rails.application.credentials.devise_jwt_secret_key!,
            true,
            algorithm: 'HS256'
          )[0]

          @current_user = User.find(decoded['sub']) # Devise JWT uses 'sub' for user ID
        rescue JWT::DecodeError, ActiveRecord::RecordNotFound
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      else
        render json: { error: 'Missing token' }, status: :unauthorized
      end
    end
  end
end