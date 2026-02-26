module Provider
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_service_provider!

    def index
      profiles = current_user.profiles.provider
      return @available_listings = [] if profiles.empty?

      service_ids = profiles.flat_map { |p| p.services.pluck(:id) }.uniq

      @available_listings = Listing.open.joins(:services).where(services: { id: service_ids }).distinct

      if current_user.unlicensed_provider?
        @available_listings = @available_listings.where("budget <= ?", 1000)
      end

      # Optional: exclude listings already bid on
      @available_listings = @available_listings.where.not(
        id: current_user.bids.select(:listing_id)
      )

      # My bids
      @my_bids = current_user.bids.includes(:listing)

      gate = AccessGate.new(current_user)
      @bids_remaining = gate.bids_remaining
    end

    private

    def ensure_service_provider!
      redirect_to root_path, alert: "Access denied: You are not a service provider." unless current_user.service_provider? || current_user.unlicensed_provider?
    end
  end
end