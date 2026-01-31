class RolesController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    case params[:role]
    when "homeowner"
      current_user.update!(role: :homeowner)
      redirect_to homeowner_dashboard_path
    when "service_provider"
      current_user.update!(role: :service_provider)
      redirect_to provider_onboarding_path
    else
      flash.now[:alert] = "Please choose a role"
      render :new, status: :unprocessable_entity
    end
  end
end