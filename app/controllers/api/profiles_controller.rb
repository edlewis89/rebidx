module Api
  class ProfilesController < Api::BaseController
    before_action :authenticate_user! # JWT authentication
    before_action :ensure_service_provider

    # POST /api/profiles
    def create
      profile = current_user.build_profile(profile_params)

      if profile.save
        render json: {
          profile: profile_response(profile),
          message: "Service Provider Profile created successfully"
        }, status: :created
      else
        render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /api/profiles/:id
    def update
      profile = current_user.profiles.find(params[:profile_id])
      if profile.update(profile_params)
        render json: {
          profile: profile_response(profile),
          message: "Service Provider Profile updated successfully"
        }
      else
        render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def ensure_service_provider
      unless current_user.service_provider?
        render json: { error: "Only service providers can create a profile" }, status: :forbidden
      end
    end

    def profile_params
      params.require(:profile).permit(
        :full_name,
        :business_name,
        :phone_number,
        :tax_id,
        :government_id,
        :business_license_number,
        :address,
        :city,
        :state,
        :zipcode,
        :latitude,
        :longitude,
        :verification_status,
        service_ids: [] # array of Service IDs
      )
    end

    def profile_response(profile)
      {
        id: profile.id,
        full_name: profile.full_name,
        business_name: profile.business_name,
        phone_number: profile.phone_number,
        address: profile.address,
        city: profile.city,
        state: profile.state,
        zipcode: profile.zipcode,
        latitude: profile.latitude,
        longitude: profile.longitude,
        verified: profile.verified,
        verification_status: profile.verification_status,
        services: profile.services.pluck(:name)
      }
    end
  end
end