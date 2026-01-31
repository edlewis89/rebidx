module Admin
  class ServiceProviderProfilesController < BaseController
    before_action :set_profile, only: [:show, :verify]

    def index
      @profiles = ServiceProviderProfile.includes(:user).order(created_at: :desc)
    end

    def show
    end

    def verify
      puts "VERIFY >>>>>>>>> ID: #{params[:id]}"
      @profile = ServiceProviderProfile.find(params[:id])
      @profile.update!(verified: true, verification_status: "verified")

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to admin_service_provider_profiles_path, notice: "Provider verified" }
      end
    end

    private

    def set_profile
      @profile = ServiceProviderProfile.find(params[:id])
    end
  end
end