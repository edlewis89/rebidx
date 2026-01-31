class Admin::VerificationsController < Admin::BaseController
  def index
    @profiles = VerificationProfile
                  .includes(:user, :verification_checks)
                  .order(updated_at: :desc)
  end

  def show
    @profile = VerificationProfile.find(params[:id])
  end

  def update
    profile = VerificationProfile.find(params[:id])

    if params[:status]
      profile.update!(status: params[:status])
    end

    redirect_to admin_verification_path(profile), notice: "Updated verification status"
  end
end
