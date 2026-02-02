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

        # Determine the next membership tier to upgrade to
        @upgrade_membership = next_membership(current_user)
      end
    end

    private

    def ensure_homeowner
      redirect_to root_path, alert: "Access denied: You are not a home owner." if current_user.service_provider?
    end
    # Returns the next available membership tier for upgrade
    def next_membership(user)
      return nil unless user.membership

      # Only include active memberships with higher price than current
      Membership
        .where("price_cents > ? AND active = ?", user.membership.price_cents, true)
        .order(price_cents: :asc)
        .first
    end
  end
end