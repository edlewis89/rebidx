class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile
  before_action :set_services_and_license_types, only: [:edit, :update]

  def edit
    # @profile, @services, @license_types are already set
  end

  def update
    ActiveRecord::Base.transaction do
      @profile.update!(profile_params)

      # Assign services if this profile has them
      if params[:service_ids].present? && @profile.respond_to?(:services)
        @profile.services = Service.where(id: params[:service_ids])
      end

      # Assign licenses if this profile has them
      if params[:license_type_ids].present? && @profile.respond_to?(:license_types)
        @profile.license_types = LicenseType.where(id: params[:license_type_ids])
      end

      # Verification handling
      if @profile.respond_to?(:requires_verification?) && @profile.requires_verification?
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
    # Grab a profile for the current user. You might adjust to select by type:
    @profile = current_user.profiles.first # or use params[:id] if editing specific
  end

  def set_services_and_license_types
    @services = Service.order(:name)
    @license_types = LicenseType.order(:name)
  end

  def profile_params
    params.require(:profile).permit(
      :business_name, :full_name, :phone_number,
      :tax_id, :government_id, :business_license_number
    )
  end
end