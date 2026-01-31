class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    if resource.admin?
      admin_root_path  # <-- your admin dashboard
    elsif resource.unassigned?
      choose_role_path
    elsif resource.service_provider? || resource.unlicensed_provider?
      if resource.provider_onboarded?
        listings_path
      else
        provider_onboarding_path
      end
    elsif resource.homeowner?
      homeowner_onboarding_path
    else
      root_path
    end
  end
end