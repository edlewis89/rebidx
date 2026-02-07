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

    # Use bid amount if provided, otherwise fallback to listing budget
    bid_amount ||= listing.budget.to_f

    # Check membership max / min bid range
    bid_amount >= @user.min_bid_amount && bid_amount <= @user.max_bid_amount
  end

  def exceeds_max_bid_range?
    listing.bid.budget > @user.max_bid_amount
  end

  #def can_bid_on_listing?(listing)
  #  true
    # # Homeowners cannot bid
    # return false unless @user.service_provider_profile
    #
    # return false if listing.complete?
    #
    # listing_service_ids  = listing.services.pluck(:id)
    # provider_service_ids = @user.service_provider_profile.services.pluck(:id)
    #
    # # If listing is custom/other
    # custom_service = Service.find_by(name: "Custom / Other")
    # if listing_service_ids == [custom_service&.id]
    #   # Optionally allow bid with warning
    #   return true
    # end
    #
    # # Standard service match
    # (listing_service_ids & provider_service_ids).any?
  #end

  def can_bid_on_listing?(listing)
    return false unless can_bid_on?(listing)

    # Require verification for high-budget jobs
    if listing.budget.to_f >= 1000
      return false unless @user.verified_provider?
    end

    true
  end

  # Reason the user cannot bid (for UI / alert)
  def blocked_bid_reason(listing)
    return "You have hit your bid limit" if bids_remaining.zero?
    return "Cannot bid on your own listing" if listing.user == @user
    return "Listing is not open" unless listing.open?
    return "Upgrade membership to bid higher" if listing.budget.to_f > @user.max_bid_amount
    return "Upload license to bid on higher-value jobs" if listing.budget.to_f > 1_000 && !licensed_provider?
    return "Verify your account to bid on high-value jobs" if listing.budget.to_f > 5_000 && !verified?

    custom_service = Service.find_by(name: "Custom / Other")
    if listing.services.include?(custom_service)
      return "⚠️ This listing is outside standard services. You can still bid if qualified."
    else
      return "You do not meet the requirements to bid on this listing."
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
