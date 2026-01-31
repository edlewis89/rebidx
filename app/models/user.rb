class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  after_create :assign_default_membership

  has_one :service_provider_profile, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_one :membership, through: :subscription
  has_one :verification_profile, dependent: :destroy
  has_many :notifications, dependent: :destroy

  has_many :bids
  has_many :listings
  has_many :properties
  has_many :ratings_given, class_name: "Rating"

  enum role: {
    unassigned: 0,
    homeowner: 1,
    service_provider: 2,
    rebidx_admin: 3
  }

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
    service_provider? && (service_provider_profile.nil? || !service_provider_profile.license_uploaded?)
  end

  # ---- License / Verification Helpers ----
  def licensed_provider?
    service_provider_profile&.license_uploaded?
  end

  def verified_provider?
    service_provider_profile&.verified_provider?
  end

  def can_bid_on?(listing)
    return false unless listing.open?

    if service_provider?
      profile = service_provider_profile
      return false unless profile

      # Handyman = no license
      if profile.license_types.empty?
        return listing.budget.to_f <= 1_000
      end

      # Licensed provider: small jobs always allowed
      return true if listing.budget.to_f <= 1_000

      # For larger jobs: check license max & verification
      max_budget = profile.max_project_budget || 1_000 # fallback
      return false if listing.budget.to_f > max_budget

      # Must be verified
      profile.verified_provider?

    else
      false
    end
  end

  def provider_onboarded?
    service_provider? && service_provider_profile.present? &&
      service_provider_profile.completed? # define `completed?` in profile
  end

  def assign_default_membership
    free = Membership.find_by(name: "Free")
    create_subscription(membership: free) if free
  end

  # ---- Reason a user cannot bid ----
  def cannot_bid_reason(listing)
    profile = service_provider_profile

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
    service_provider? && service_provider_profile&.license_types.blank?
  end
end
