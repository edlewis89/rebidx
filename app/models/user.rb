class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,           # <-- add this
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  before_create :auto_confirm_if_disabled
  after_create :assign_default_membership

  has_one :subscription, dependent: :destroy
  has_one :membership, through: :subscription
  has_one :verification_profile, dependent: :destroy

  has_many :notifications, dependent: :destroy
  has_many :profiles, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :bids, through: :profiles, source: :bids
  has_many :listings, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :ratings_received, through: :profiles, source: :ratings_received

  enum role: { 
    unassigned: 0,
    homeowner: 1,
    service_provider: 2,
    rebidx_admin: 3
  }

  # Stripe Connect account ID for providers
  # This allows payouts to providers
  # Example: "acct_123456789"
  attribute :stripe_account_id, :string

  # ---- Role Helpers ----
  def service_provider?
    role == "service_provider"
  end

  def homeowner?
    role == "homeowner"
  end

  def admin?
    role == "rebidx_admin"
  end

  def handyman?
    service_provider? && !profile.license_uploaded?
  end

  # ---- License / Verification Helpers ----
  def licensed_provider?
    profiles.any?(&:license_uploaded?)
  end

  def verified_provider?
    profiles.any?(&:verified_provider?)
  end

  # def bid_range
  #   features&.fetch("bid_range", {}) || {}
  # end

  def max_bid_amount
    bid_range.is_a?(Array) ? bid_range[1].to_i : 0
  end

  def min_bid_amount
    bid_range.is_a?(Array) ? bid_range[0].to_i : 0
  end

  def provider_onboarded?
    service_provider? && profile.present? &&
      profile.completed? # define `completed?` in profile
  end

  def assign_default_membership
    free = Membership.find_by(name: "Free")
    create_subscription(membership: free) if free
  end

  # ---- Reason a user cannot bid ----
  def cannot_bid_reason(listing)
    # Handyman / unlicensed
    if profile.nil? || !profile.license_uploaded?
      return "You can only bid on jobs $1,000 or less" if listing.budget.to_f > 1_000
    end

    # Licensed provider but not verified
    if profile&.requires_verification? && !profile.verified_provider? && listing.budget.to_f > profile.max_project_budget
      return "Provider must be verified to bid on high-value jobs"
    end

    nil
  end

  def ensure_verification_profile!
    verification_profile || create_verification_profile(status: "unverified")
  end

  def unlicensed_provider?
    return false unless service_provider?

    # Check if any of the profiles have licenses
    profiles.any? { |p| p.profile_type == "unlicensed_provider" || p.license_types.blank? }
  end

  # Return the allowed bid range [low, high] from current membership
  # Returns the allowed bid range [min, max] from the current membership features
  def bid_range
    # fallback if no membership or feature missing
    default_range = { "low" => 0, "high" => 1_000 }

    features_range = membership&.features&.dig("bid_range") || default_range
    [features_range["low"].to_f, features_range["high"].to_f]
  end

  protected_methods

  # ✅ instance method
  def auto_confirm_if_disabled
    return if self.class.email_verification_enabled?
    self.confirmed_at ||= Time.current
  end

  # ✅ override Devise hook
  def send_on_create_confirmation_instructions
    return unless self.class.email_verification_enabled?
    super
  end

  # ✅ CLASS METHOD — MUST be inside class
  def self.email_verification_enabled?
    ActiveModel::Type::Boolean.new.cast(
      ENV.fetch("EMAIL_VERIFICATION_ENABLED", true)
    )
  end
end



# def can_bid_on?(listing)
#   listing.budget.to_i <= max_bid_amount
# end
#
# def lock_reason(listing)
#   return "Upgrade membership to bid higher" if listing.budget > max_bid_amount
#   return "Upload license to bid on higher-value jobs" if listing.budget > 1000 && !license_verified?
#   return "Verify your account to unlock bidding" if listing.budget > 5000 && !verified?
#   nil
# end

# def can_bid_on?(listing)
#   return false unless listing.open?
#
#   if service_provider?
#     profile = service_provider_profile
#     return false unless profile
#
#     # Handyman = no license
#     if profile.license_types.empty?
#       return listing.budget.to_f <= 1_000
#     end
#
#     # Licensed provider: small jobs always allowed
#     return true if listing.budget.to_f <= 1_000
#
#     # For larger jobs: check license max & verification
#     max_budget = profile.max_project_budget || 1_000 # fallback
#     return false if listing.budget.to_f > max_budget
#
#     # Must be verified
#     profile.verified_provider?
#
#   else
#     false
#   end
# end
