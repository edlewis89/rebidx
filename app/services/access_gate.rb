class AccessGate
  def initialize(user)
    @user = user
    @membership = MembershipGate.new(user)
    @verification = user&.verification_profile
  end

  # --- Listings ---
  def can_create_listing?
    verified? && @membership.can_create_listing?
  end

  def listings_remaining
    return 0 unless verified?
    @membership.listings_remaining
  end

  # --- Bidding ---
  def can_bid?
    verified? && @membership.can_bid?
  end

  def bids_remaining
    return 0 unless verified?
    @membership.bids_remaining
  end

  # --- Messaging ---
  def can_message?
    verified? && feature?(:messaging)
  end

  # --- Featured Listings ---
  def can_feature_listing?
    verified? && feature?(:featured_listings)
  end

  def can_bid_on?(listing)
    return false unless can_bid?
    return false if listing.user == @user
    return false unless listing.open?

    true
  end

  private

  def verified?
    @verification&.verified?
  end

  def feature?(feature)
    @membership.allowed?(feature)
  end
end