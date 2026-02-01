class MembershipGate
  def initialize(user)
    @user = user
    @membership = user.membership
  end

  def allowed?(feature)
    return false unless @membership
    @membership.features[feature.to_s] == true
  end

  def limit(feature)
    return 0 unless @membership
    @membership.features[feature.to_s].to_i
  end

  # ---- Listings ----
  def listings_remaining
    remaining = limit(:max_listings) - Listing.where(user: @user).count
    remaining.positive? ? remaining : 0
  end

  def can_create_listing?
    Listing.where(user: @user).count < limit(:max_listings)
  end

  # ---- Bids ----
  def bids_remaining
    remaining = limit(:max_bids_per_month) - current_month_bids_count
    remaining.positive? ? remaining : 0
  end

  def can_bid?
    bids_remaining > 0
  end

  # ---- High Value Jobs ----
  def can_bid_high_value?
    allowed?(:can_bid_high_value)
  end

  # ---- Messaging ----
  def messaging_enabled?
    allowed?(:messaging)
  end

  # ---- Ads ----
  def show_ads?
    allowed?(:show_ads)
  end

  # ---- Verification ----
  def requires_verification?
    allowed?(:requires_verification)
  end

  private

  def current_month_bids_count
    @user.bids.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month).count
  end
end