class Membership < ApplicationRecord
  has_many :subscriptions
  # Features stored as a JSON column
  # PostgreSQL jsonb columns already store hashes/arrays as JSON, and Rails automatically converts them to Ruby Hash/Array when you read/write.
  # serialize :features, JSON

  # Define all keys for strong params
  FEATURE_KEYS = %i[
    max_listings
    max_bids_per_month
    messaging
    featured_listings
    priority_support
  ]

  FEATURE_TYPES = {
    max_listings: :numeric,
    max_bids_per_month: :numeric,
    messaging: :boolean,
    featured_listings: :boolean,
    priority_support: :boolean
  }
end
