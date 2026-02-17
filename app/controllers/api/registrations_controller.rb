# app/controllers/api/registrations_controller.rb
module Api
  class RegistrationsController < Devise::RegistrationsController
    # Skip CSRF for API
    skip_before_action :verify_authenticity_token
    respond_to :json

    # POST /api/signup
    def create
      build_resource(sign_up_params)

      if resource.save
        resource.create_service_provider_profile if resource.service_provider?

        # 🔥 ONLY send confirmation if feature enabled
        if FeatureFlags.email_verification_enabled?
          begin
            # Send confirmation email immediately
            UserMailer.confirmation_email(resource).deliver_now
          rescue => e
            Rails.logger.error "Email confirmation failed: #{e.class} - #{e.message}"
          end
        else
          # 🚀 Auto-confirm in dev / free tier
          resource.confirm if resource.respond_to?(:confirm)
        end

        render json: {
          user: user_response(resource),
          message: signup_message(resource)
          # message: "Signup successful. Confirmation email sent to #{resource.email}."
        }, status: :created
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    rescue => e
      Rails.logger.error "Signup failed: #{e.class} - #{e.message}"
      render json: { error: "Signup failed: #{e.message}" }, status: :internal_server_error
    end

    # POST /api/signup
    # def create
    #   build_resource(sign_up_params)
    #
    #   if resource.save
    #     resource.generate_confirmation_token! if resource.respond_to?(:generate_confirmation_token!)
    #     resource.save!
    #
    #     resource.create_service_provider_profile if resource.service_provider?
    #
    #     confirmation_link = "#{ENV['APP_HOST']}/users/confirmation?confirmation_token=#{resource.confirmation_token}"
    #
    #     Rails.logger.info("confirmation_link: #{confirmation_link}")
    #
    #     begin
    #       SendgridMailer.send_email(
    #         to: resource.email,
    #         subject: "Confirm your Rebidx account",
    #         html: "<p>Click to confirm:</p><a href='#{confirmation_link}'>Confirm Account</a>"
    #       )
    #     rescue => e
    #       Rails.logger.error "SendGrid failed: #{e.message}"
    #     end
    #
    #     render json: {
    #       user: user_response(resource),
    #       message: "Confirmation email sent to #{resource.email}. Please verify your email before logging in."
    #     }, status: :created
    #   else
    #     render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    #   end
    # end

    private

    def sign_up_params
      params.require(:user).permit(
        :name,
        :email,
        :password,
        :password_confirmation,
        :role,
        :zipcode,
        :phone
      )
    end

    def user_response(user)
      {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        service_provider_profile_created: user.service_provider_profile.present?
      }
    end
  end
end
