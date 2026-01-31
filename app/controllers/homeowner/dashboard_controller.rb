module Homeowner
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_homeowner

    def index
      @listings = current_user.listings.includes(:bids, :services, :property).order(created_at: :desc)

      # For UI only — do NOT block access
      if current_user
        gate = ::MembershipGate.new(current_user)
        @listings_remaining = gate.listings_remaining
      end
    end

    private

    def ensure_homeowner
      redirect_to root_path, alert: "Access denied: You are not a home owner." if current_user.service_provider?
    end
  end
end