class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile
  before_action :set_services_and_license_types, only: [:edit, :update]

  def edit
    # @profile is already set
    # @services and @license_types set by before_action
  end

  def update
    ActiveRecord::Base.transaction do
      @profile.update!(profile_params)

      # Services
      @profile.services = Service.where(id: params[:service_ids])

      # Licenses
      @profile.license_types = LicenseType.where(id: params[:license_type_ids])

      # Verification handling
      if @profile.requires_verification?
        @profile.update!(verified: false, verification_status: "pending")
      else
        @profile.update!(verified: true, verification_status: "not_required")
      end
    end

    redirect_to listings_path, notice: "Profile updated 🎉"
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_entity
  end

  private

  def set_profile
    @profile = current_user.service_provider_profile
  end

  def set_services_and_license_types
    @services = Service.order(:name)
    @license_types = LicenseType.order(:name)
  end

  def profile_params
    params.require(:service_provider_profile).permit(
      :business_name, :full_name, :phone_number,
      :tax_id, :government_id, :business_license_number
    )
  end
end
