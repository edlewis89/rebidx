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
          decoded = JWT.decode(
            token,
            Rails.application.credentials.secret_key_base,
            true,
            algorithm: 'HS256'
          )[0]

          @current_user = User.find(decoded['sub'])
        rescue
          render json: { error: 'Unauthorized' }, status: :unauthorized
        end
      else
        render json: { error: 'Missing token' }, status: :unauthorized
      end
    end
  end
end