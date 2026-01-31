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

  # Calculates how many listings the user can still create
  def listings_remaining
    remaining = limit(:max_listings) - Listing.where(user: @user).count
    remaining.positive? ? remaining : 0
  end

  # Boolean check if user can create a new listing
  def can_create_listing?
    Listing.where(user: @user).count < limit(:max_listings)
  end

  # ✅ New method: can the user place a bid?
  def bids_remaining
    return 0 unless @membership
    # Count bids placed in current month
    #
    remaining = limit(:max_bids_per_month) - current_month_bids_count
    remaining.positive? ? remaining : 0
  end

  def can_bid?
    bids_remaining > 0
  end

  private

  def current_month_bids_count
    @user.bids.where(created_at: Time.current.beginning_of_month..Time.current.end_of_month).count
  end
end
