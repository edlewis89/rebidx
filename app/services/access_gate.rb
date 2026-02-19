# Key changes:
# Now works with profile instead of user.
#
#   You pass a profile to AccessGate.new(profile) instead of AccessGate.new(user).
#
#   Profile-specific rules:
#
#   Homeowner, service provider, or unlicensed provider can now have independent verification and limits.
#
#   Verification checks are tied to the profile, not the user.
#
#     All feature flags and membership limits remain user-scoped (since membership is still tied to the user).
#
#   licensed_provider? and verified? now check the profile, not the user.

class AccessGate
  def initialize(profile)
    @profile = profile
    @user = profile.user
    @membership = MembershipGate.new(@user)
    @verification = profile.verification_profile
  end

  # --- Listings ---
  def can_create_listing?
    return false unless @membership.can_create_listing?

    if @profile.homeowner?
      return true unless FeatureFlags.email_verification_enabled?
      return @user.confirmed?
    end

    # Provider rules
    return true unless licensed_provider?
    verified?
  end

  def listings_remaining
    return 0 unless licensed_provider? ? verified? : true
    @membership.listings_remaining
  end

  # --- Bidding ---
  def can_bid?
    return false unless @membership.can_bid?
    return true unless licensed_provider?

    verified?
  end

  def bids_remaining
    return 0 unless licensed_provider? ? verified? : true
    @membership.bids_remaining
  end

  def can_bid_on?(listing)
    return false unless can_bid?
    return false if listing.user == @user
    return false unless listing.open?

    bid_amount = listing.budget.to_f
    bid_amount >= @profile.min_bid_amount && bid_amount <= @profile.max_bid_amount
  end

  def can_bid_on_listing?(listing)
    return false unless can_bid_on?(listing)

    if listing.budget.to_f >= 1_000
      return false unless verified?
    end

    true
  end

  # --- Messaging ---
  def can_message?
    return false unless feature?(:messaging)
    return true unless licensed_provider?

    verified?
  end

  # --- Featured Listings ---
  def can_feature_listing?
    return false unless feature?(:featured_listings)
    return true unless licensed_provider?

    verified?
  end

  # --- UI Helpers ---
  def blocked_bid_reason(listing)
    return "You have hit your bid limit" if bids_remaining.zero?
    return "Cannot bid on your own listing" if listing.user == @user
    return "Listing is not open" unless listing.open?
    return "Upgrade membership to bid higher" if listing.budget.to_f > @profile.max_bid_amount
    return "Upload license to bid on higher-value jobs" if listing.budget.to_f > 1_000 && !licensed_provider?
    return "Verify your account to bid on high-value jobs" if listing.budget.to_f > 5_000 && !verified?

    custom_service = Service.find_by(name: "Custom / Other")
    if listing.services.include?(custom_service)
      "⚠️ This listing is outside standard services. You can still bid if qualified."
    else
      "You do not meet the requirements to bid on this listing."
    end
  end

  # --- Feature flags ---
  def can_message_homeowners?
    @membership.allowed?("can_message_homeowners")
  end
  def featured_priority?
    @membership.allowed?("featured_priority")
  end
  def profile_boost?
    @membership.allowed?("profile_boost")
  end

  private

  def licensed_provider?
    @profile.provider? && @profile.licensed?
  end

  def verified?
    @verification&.verified? || false
  end

  def feature?(feature)
    @membership.allowed?(feature)
  end
end

