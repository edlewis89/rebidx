class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

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
    return choose_role_path if resource.unassigned?

    case resource.role
    when "service_provider"
      return provider_onboarding_path if resource.profiles.blank?
      provider_dashboard_path

    when "homeowner"
      homeowner_dashboard_path

    # when "investor"
    #   investor_dashboard_path

    when "rebidx_admin"
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
    return unless current_user.service_provider?
    return if current_user.profiles.provider.exists?
    return unless request.get?
    return if request.path.start_with?(provider_onboarding_path)

    redirect_to provider_onboarding_path
  end
end
