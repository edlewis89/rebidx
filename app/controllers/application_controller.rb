class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :redirect_unassigned_users
  before_action :redirect_unfinished_providers

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # After login, send user to appropriate dashboard or onboarding
  def after_sign_in_path_for(resource)
    # Unassigned users go choose role
    return choose_role_path if resource.unassigned?

    if resource.service_provider?
      # If profile is not yet set up, send to onboarding
      if resource.service_provider_profile.nil?
        provider_onboarding_path
      else
        provider_dashboard_path
      end
    elsif resource.homeowner?
      homeowner_dashboard_path
    elsif resource.admin?
      admin_root_path
    else
      root_path
    end
  end

  private

  # Redirect unassigned users to choose role
  def redirect_unassigned_users
    return unless user_signed_in?
    return unless current_user.unassigned?
    return if request.path == choose_role_path

    redirect_to choose_role_path
  end

  # Redirect service providers/handymen without profile to onboarding
  def redirect_unfinished_providers
    return unless user_signed_in?
    return unless current_user.service_provider? || current_user.unlicensed_provider?
    return if current_user.service_provider_profile.present?
    return unless request.get? # don't redirect on form POST

    # Avoid redirect loop by skipping if already on onboarding
    return if request.path.start_with?(provider_onboarding_path)

    redirect_to provider_onboarding_path
  end
end
