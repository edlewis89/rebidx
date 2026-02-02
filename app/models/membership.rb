class Membership < ApplicationRecord
  has_many :subscriptions

  FEATURE_KEYS = %i[
    max_listings
    max_bids_per_month
    messaging
    featured_listings
    priority_support
    bid_range
  ]

  FEATURE_TYPES = {
    max_listings: :numeric,
    max_bids_per_month: :numeric,
    messaging: :boolean,
    featured_listings: :boolean,
    priority_support: :boolean,
    bid_range: :range_hash
  }

  # Helper to get bid range per license type
  def bid_range_for(license_class)
    features.dig("bid_range", license_class.to_s) || { "min" => 0, "max" => 1000 }
  end
end

