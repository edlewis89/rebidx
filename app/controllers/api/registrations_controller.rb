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
        # If the user is a service provider, create profile
        resource.create_service_provider_profile if resource.service_provider?

        # Optionally, create a homeowner profile here if you want symmetry
        # resource.create_homeowner_profile if resource.homeowner?

        # Send confirmation instructions
        # resource.send_confirmation_instructions
        confirmation_link = "#{ENV['APP_HOST']}/users/confirmation?confirmation_token=#{resource.confirmation_token}"

        SendgridMailer.send_email(
          to: resource.email,
          subject: "Confirm your Rebidx account",
          html: "<p>Click to confirm:</p><a href='#{confirmation_link}'>Confirm Account</a>"
        )

        render json: {
          user: user_response(resource),
          message: "Confirmation email sent to #{resource.email}. Please verify your email before logging in."
        }, status: :created
      else
        render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
      end
    end

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
