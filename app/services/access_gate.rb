# Key changes:
#  Added licensed_provider? helper.
#  Only enforce verified? checks for licensed providers.
#  Unlicensed providers can still create listings / bid without a verification profile.
#  All methods now always return a boolean (true or false), never nil.

class AccessGate
  def initialize(user)
    @user = user
    @membership = MembershipGate.new(user)
    @verification = user&.verification_profile
  end

  # --- Listings ---
  def can_create_listing?
    return false unless @membership.can_create_listing?
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

  def can_bid_on?(listing)
    return false unless can_bid?
    return false if listing.user == @user
    return false unless listing.open?

    true
  end

  def can_bid_on_listing?(listing)
    return false unless can_bid?

    # Require verification for high-budget jobs
    if listing.budget.to_f >= 1000
      return false unless @user.verified_provider?
    end

    true
  end

  def blocked_bid_reason(listing)
    return "Membership bid limit reached" if bids_remaining.to_i <= 0

    if listing.budget.to_f >= 1000 && !@user.verified_provider?
      return "Verification required for jobs over $1,000"
    end

    nil
  end

  def can_message_homeowners?
    @features["can_message_homeowners"] == true
  end

  def featured_priority?
    @features["featured_priority"] == true
  end

  def profile_boost?
    @features["profile_boost"] == true
  end

  private

  def licensed_provider?
    @user.service_provider? && @user.licensed_provider?
  end

  def verified?
    @verification&.verified? || false
  end

  def feature?(feature)
    @membership.allowed?(feature)
  end
end
