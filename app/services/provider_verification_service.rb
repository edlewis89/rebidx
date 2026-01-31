class ProviderVerificationService
  def initialize(user)
    @user = user
    @profile = user.service_provider_profile
    @gate = MembershipGate.new(user)
  end

  def status
    return :not_applicable unless @user.service_provider?
    return :verified if verified?
    return :not_required if not_required?
    return :pending if pending?
    return :rejected if rejected?
    return :unverified
  end

  def can_bid_on?(listing)
    user.can_bid_on?(listing)
  end

  # def can_bid_on?(listing)
  #   return true if verified?
  #   return true if handyman_allowed?(listing)
  #   return true if free_tier_limited_bid_allowed?
  #   return license_valid? if high_value_job?(listing)
  #
  #   false
  # end

  def needs_license_upload?(listing)
    high_value_job?(listing) && !license_valid?
  end

  def reason_for_block(listing)
    return "Handymen may only bid under $1,000" if handyman_blocked?(listing)
    return "Upload license to bid on high-value jobs" if needs_license_upload?(listing)
    return "Membership bid limit reached" unless @gate.can_bid?
    return "Verification pending" if pending?
    return "Verification rejected" if rejected?

    "Verification required"
  end

  private

  def verified?
    @profile&.verified?
  end

  def pending?
    @profile&.pending?
  end

  def rejected?
    @profile&.rejected?
  end

  def not_required?
    @profile&.not_required?
  end

  def license_valid?
    @profile&.license_valid?
  end

  def high_value_job?(listing)
    listing.budget.to_f >= 1000
  end

  def handyman_allowed?(listing)
    @user.unlicensed_provider? && listing.budget.to_f < 1000
  end

  def handyman_blocked?(listing)
    @user.unlicensed_provider? && listing.budget.to_f >= 1000
  end

  def free_tier_limited_bid_allowed?
    @gate.can_bid?
  end
end
