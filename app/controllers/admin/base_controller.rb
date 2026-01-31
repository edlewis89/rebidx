module Admin
  class BaseController < ApplicationController
    layout "admin"  # Rails will use app/views/layouts/admin.html.erb
    before_action :authenticate_user!
    before_action :require_admin

    private

    def require_admin
      unless current_user&.admin?
        flash[:alert] = "Access denied."
        redirect_to root_path
      end
    end
  end
end