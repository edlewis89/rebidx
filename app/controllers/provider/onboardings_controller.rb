module Provider
  class OnboardingsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_provider_role
    before_action :set_profile

    def show
      @services = Service.order(:name)
      @license_types = LicenseType.order(:name)
    end

    def edit
      @services = Service.order(:name)
      @license_types = LicenseType.order(:name)
    end

    def update
      ActiveRecord::Base.transaction do
        @profile.update!(profile_params)

        @profile.services =
          Service.where(id: params[:service_ids])

        @profile.license_types =
          LicenseType.where(id: params[:license_type_ids])

        handle_verification!
      end

      redirect_to provider_dashboard_path, notice: "Profile saved 🎉"
    rescue ActiveRecord::RecordInvalid
      load_dependencies
      render action_name == "edit" ? :edit : :show,
             status: :unprocessable_entity
    end

    private

    def load_dependencies
      @services = Service.order(:name)
      @license_types = LicenseType.order(:name)
    end

    def handle_verification!
      if @profile.requires_verification?
        @profile.update!(verification_status: :pending)
      else
        @profile.update!(verification_status: :not_required)
      end
    end
    def ensure_provider_role
      redirect_to choose_role_path unless current_user.service_provider? || current_user.unlicensed_provider?
    end

    def set_profile
      # pick the first provider profile if it exists
      @profile = current_user.profiles.find_by(profile_type: :provider)

      # otherwise, build a new provider profile
      @profile ||= current_user.profiles.build(profile_type: :provider)
    end

    def profile_params
      params.require(:profile).permit(
        :business_name,
        :full_name,
        :phone_number,
        :tax_id,
        :government_id,
        :business_license_number
      )
    end
  end
end